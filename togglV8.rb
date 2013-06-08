#! /usr/bin/env rvm ruby-1.9.3-head do ruby

require 'rubygems'
require 'awesome_print'
require 'logger'

require 'faraday'
require 'faraday_middleware'
require 'json'

class Toggl
  attr_accessor :conn, :debug

  def initialize(username=nil, password='api_token', debug=nil)
    self.debug(debug) if !debug.nil?
    if (password.to_s == 'api_token' && username.to_s == '')
      toggl_api_file = ENV['HOME']+'/.toggl'
      if FileTest.exist?(toggl_api_file) then
        username = IO.read(toggl_api_file)
      else
        raise "Expecting api_token in file ~/.toggl or parameters (api_token) or (username, password)"
      end
    end

    @conn = connection(username, password)
  end

  def connection(username, password)
    conn = Faraday.new(url: 'https://www.toggl.com/api/v8')
    conn.headers = {"Content-Type" => "application/json"}
    conn.basic_auth username, password
    conn.use Faraday::Response::Logger, Logger.new('faraday.log')
    conn
  end

  def debug(debug=true)
    puts "debugging is %s" % [debug ? "ON" : "OFF"]
    @debug = debug
  end

#----------#
#--- Me ---#
#----------#

  def me(all=nil)
    res = get "me%s" % [all.nil? ? "" : "?with_related_data=#{all}"]
  end

#---------------#
#--- Clients ---#
#---------------#

# name  : The name of the client (string, required, unique in workspace)
# wid   : workspace ID, where the client will be used (integer, required)
# notes : Notes for the client (string, not required)
# hrate : The hourly rate for this client (float, not required, available only for pro workspaces)
# cur   : The name of the client's currency (string, not required, available only for pro workspaces)
# at    : timestamp that is sent in the response, indicates the time client was last updated

  def workspace_clients(workspace)
    get "workspaces/#{workspace}/clients"
  end

#----------------#
#--- Projects ---#
#----------------#

# name        : The name of the project (string, required, unique for client and workspace)
# wid         : workspace ID, where the project will be saved (integer, required)
# cid         : client ID(integer, not required)
# active      : whether the project is archived or not (boolean, by default true)
# is_private  : whether project is accessible for only project users or for all workspace users (boolean, default true)
# template    : whether the project can be used as a template (boolean, not required)
# template_id : id of the template project used on current project's creation
# billable    : whether the project is billable or not (boolean, default true, available only for pro workspaces)
# at          : timestamp that is sent in the response for PUT, indicates the time task was last updated

  def projects(workspace)
    get "workspaces/#{workspace}/projects"
  end

  def create_project(params={})
    post "projects", {project: params}
  end

#---------------------#
#--- Project users ---#
#---------------------#

# pid      : project ID (integer, required)
# uid      : user ID, who is added to the project (integer, required)
# wid      : workspace ID, where the project belongs to (integer, not-required, project's workspace id is used)
# manager  : admin rights for this project (boolean, default false)
# rate     : hourly rate for the project user (float, not-required, only for pro workspaces) in the currency of the project's client or in workspace default currency.
# at       : timestamp that is sent in the response, indicates when the project user was last updated
# --Additional fields--
# fullname : full name of the user, who is added to the project

#------------#
#--- Tags ---#
#------------#

# name : The name of the tag (string, required, unique in workspace)
# wid  : workspace ID, where the tag will be used (integer, required)

#-------------#
#--- Tasks ---#
#-------------#

# name              : The name of the task (string, required, unique in project)
# pid               : project ID for the task (integer, required)
# wid               : workspace ID, where the task will be saved (integer, project's workspace id is used when not supplied)
# uid               : user ID, to whom the task is assigned to (integer, not required)
# estimated_seconds : estimated duration of task in seconds (integer, not required)
# active            : whether the task is done or not (boolean, by default true)
# at                : timestamp that is sent in the response for PUT, indicates the time task was last updated
# --Additional fields--
# done_seconds      : duration (in seconds) of all the time entries registered for this task
# uname             : full name of the person to whom the task is assigned to

  def tasks(workspace, params={})
    active = params[:active].nil? ? "" : "?active=#{params[:active]}"
    get "workspaces/#{workspace}/tasks#{active}"
  end

  def create_task(params={})
    post "tasks", {task: params}
  end

  def get_task(task_id)
    get "tasks/#{task_id}"
  end

  # ex: update_task(1894675, {active: true, estimated_seconds: 4500, fields: "done_seconds,uname"})
  def update_task(*task_id, params)
    raise ArgumentError, 'params is not a Hash' unless params.is_a? Hash
    put "tasks/#{task_id.join(',')}", {task: params}
  end

  def delete_task(*task_id)
    delete "tasks/#{task_id.join(',')}"
  end

#--------------------#
#--- Time entries ---#
#--------------------#

# description  : (string, required)
# wid          : workspace ID (integer, required if pid or tid not supplied)
# pid          : project ID (integer, not required)
# tid          : task ID (integer, not required)
# billable     : (boolean, not required, default false, available for pro workspaces)
# start        : time entry start time (string, required, ISO 8601 date and time)
# stop         : time entry stop time (string, not required, ISO 8601 date and time)
# duration     : time entry duration in seconds. If the time entry is currently running, the duration attribute contains a negative value, denoting the start of the time entry in seconds since epoch (Jan 1 1970). The correct duration can be calculated as current_time + duration, where current_time is the current time in seconds since epoch. (integer, required)
# created_with : the name of your client app (string, required)
# tags         : a list of tag names (array of strings, not required)
# duronly      : should Toggl show the start and stop time of this time entry? (boolean, not required)
# at           : timestamp that is sent in the response, indicates the time item was last updated

#-------------#
#--- Users ---#
#-------------#

# api_token                 : (string)
# default_wid               : default workspace id (integer)
# email                     : (string)
# jquery_timeofday_format   : (string)
# jquery_date_format        :(string)
# timeofday_format          : (string)
# date_format               : (string)
# store_start_and_stop_time : whether start and stop time are saved on time entry (boolean)
# beginning_of_week         : (integer, Sunday=0)
# language                  : user's language (string)
# image_url                 : url with the user's profile picture(string)
# sidebar_piechart          : should a piechart be shown on the sidebar (boolean)
# at                        : timestamp of last changes
# new_blog_post             : an object with toggl blog post title and link

  def users(workspace)
    get "workspaces/#{workspace}/users"
  end

#------------------#
#--- Workspaces ---#
#------------------#

# name    : (string, required)
# premium : If it's a pro workspace or not. Shows if someone is paying for the workspace or not (boolean, not required)
# at      : timestamp that is sent in the response, indicates the time item was last updated

  def workspaces
    get "workspaces"
  end

#---------------#
#--- Private ---#
#---------------#

  private

  def get(resource)
    puts "GET #{resource}" if @debug
    full_res = self.conn.get(resource)
    res = JSON.parse(full_res.env[:body])
    res.is_a?(Array) || res['data'].nil? ? res : res['data']
  end

  def post(resource, data)
    puts "POST #{resource} / #{data}" if @debug
    full_res = self.conn.post(resource, JSON.generate(data))
    ap full_res
    res = JSON.parse(full_res.env[:body])
    ap res
    res['data'].nil? ? res : res['data']
  end

  def put(resource, data)
    puts "PUT #{resource} / #{data}" if @debug
    full_res = self.conn.put(resource, JSON.generate(data))
    res = JSON.parse(full_res.env[:body])
    res['data'].nil? ? res : res['data']
  end

  def delete(resource)
    puts "DELETE #{resource}" if @debug
    full_res = self.conn.delete(resource)
  end

end