require 'faraday'
require 'logger'
require 'oj'
require 'awesome_print' # for debug output

require_relative 'togglv8/version'
require_relative 'togglv8/users'

# :compat mode will convert symbols to strings
Oj.default_options = { mode: :compat }

module Toggl
  TOGGL_API_URL = 'https://www.toggl.com/api/'

  class V8
    TOGGL_API_V8_URL = TOGGL_API_URL + 'v8/'
    API_TOKEN = 'api_token'

    attr_accessor :conn

    def initialize(username=nil, password=API_TOKEN, opts={})
      if username.nil? && password == API_TOKEN
        toggl_api_file = ENV['HOME']+'/.toggl'
        if FileTest.exist?(toggl_api_file) then
          username = IO.read(toggl_api_file)
        else
          raise SystemCallError,
            "\tExpecting 1) api_token in file ~/.toggl, or 2) (api_token), or 3) (username, password).\n" +
            "\tSee https://github.com/toggl/toggl_api_docs/blob/master/chapters/authentication.md"
        end
      end

      @conn = Toggl::V8.connection(username, password, opts)
    end

    def self.connection(username, password, opts={})
      Faraday.new(url: TOGGL_API_V8_URL, ssl: {verify: true}) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger, Logger.new('faraday.log') if opts[:log]
        faraday.adapter Faraday.default_adapter
        faraday.headers = { "Content-Type" => "application/json" }
        faraday.basic_auth username, password
      end
    end

    def debug_on(debug=true)
      puts "debugging is %s" % [debug ? "ON" : "OFF"]
      @debug = debug
    end

    def checkParams(params, fields=[])
      raise ArgumentError, 'params is not a Hash' unless params.is_a? Hash
      return if fields.empty?
      errors = []
      for f in fields
        errors.push("params[#{f}] is required") unless params.has_key?(f)
      end
      raise ArgumentError, errors.join(', ') if !errors.empty?
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

    def create_client(params)
      checkParams(params, [:name, :wid])
      post "clients", {client: params}
    end

    def get_client(client_id)
      get "clients/#{client_id}"
    end

    def update_client(client_id, params)
      put "clients/#{client_id}", {client: params}
    end

    def delete_client(client_id)
      delete "clients/#{client_id}"
    end

    def get_client_projects(client_id, params={})
      active = params.has_key?(:active) ? "?active=#{params[:active]}" : ""
      get "clients/#{client_id}/projects#{active}"
    end


#--------------------#
#--- Time entries ---#
#--------------------#
#
# https://github.com/toggl/toggl_api_docs/blob/master/chapters/time_entries.md
#
# description  : (string, strongly suggested to be used)
# wid          : workspace ID (integer, required if pid or tid not supplied)
# pid          : project ID (integer, not required)
# tid          : task ID (integer, not required)
# billable     : (boolean, not required, default false, available for pro workspaces)
# start        : time entry start time (string, required, ISO 8601 date and time)
# stop         : time entry stop time (string, not required, ISO 8601 date and time)
# duration     : time entry duration in seconds. If the time entry is currently running,
#                the duration attribute contains a negative value,
#                denoting the start of the time entry in seconds since epoch (Jan 1 1970).
#                The correct duration can be calculated as current_time + duration,
#                where current_time is the current time in seconds since epoch. (integer, required)
# created_with : the name of your client app (string, required)
# tags         : a list of tag names (array of strings, not required)
# duronly      : should Toggl show the start and stop time of this time entry? (boolean, not required)
# at           : timestamp that is sent in the response, indicates the time item was last updated

  def create_time_entry(params)
    checkParams(params, [:description, :start, :duration, :created_with])
    if !params.has_key?(:wid) and !params.has_key?(:pid) and !params.has_key?(:tid) then
      raise ArgumentError, "one of params['wid'], params['pid'], params['tid'] is required"
    end
    post "time_entries", {time_entry: params}
  end

  def start_time_entry(params)
    if !params.has_key?(:wid) and !params.has_key?(:pid) and !params.has_key?(:tid) then
      raise ArgumentError, "one of params['wid'], params['pid'], params['tid'] is required"
    end
    post "time_entries/start", {time_entry: params}
  end

  def stop_time_entry(time_entry_id)
    put "time_entries/#{time_entry_id}/stop", {}
  end

  def get_time_entry(time_entry_id)
    get "time_entries/#{time_entry_id}"
  end

  def update_time_entry(time_entry_id, params)
    put "time_entries/#{time_entry_id}", {time_entry: params}
  end

  def delete_time_entry(time_entry_id)
    delete "time_entries/#{time_entry_id}"
  end

  def iso8601(date)
    return nil if date.nil?
    if date.is_a?(Time) or date.is_a?(Date)
      iso = date.iso8601
    elsif date.is_a?(String)
      iso =  DateTime.parse(date).iso8601
    else
      raise ArgumentError, "Can't convert #{date.class} to ISO-8601 Date/Time"
    end
    return Faraday::Utils.escape(iso)
  end

  def get_time_entries(start_date=nil, end_date=nil)
    params = []
    params.push("start_date=#{iso8601(start_date)}") if !start_date.nil?
    params.push("end_date=#{iso8601(end_date)}") if !end_date.nil?
    get "time_entries%s" % [params.empty? ? "" : "?#{params.join('&')}"]
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

    def clients(workspace=nil)
      if workspace.nil?
        get "clients"
      else
        get "workspaces/#{workspace}/clients"
      end
    end

    def projects(workspace, params={})
      active = params.has_key?(:active) ? "?active=#{params[:active]}" : ""
      get "workspaces/#{workspace}/projects#{active}"
    end

    def users(workspace)
      get "workspaces/#{workspace}/users"
    end

    def tasks(workspace, params={})
      active = params.has_key?(:active) ? "?active=#{params[:active]}" : ""
      get "workspaces/#{workspace}/tasks#{active}"
    end

#---------------#
#--- Private ---#
#---------------#

  private

    def get(resource)
      puts " ----------- " if @debug
      puts "GET #{resource}" if @debug
      full_res = self.conn.get(resource)
      ap full_res.env if @debug
      res = Oj.load(full_res.env[:body])
      res.is_a?(Array) || res['data'].nil? ? res : res['data']
    end

    def post(resource, data='')
      puts " ----------- " if @debug
      puts "POST #{resource} / #{data}" if @debug
      full_res = self.conn.post(resource, Oj.dump(data))
      ap full_res if @debug
      ap full_res.env if @debug
      if (200 == full_res.env[:status]) then
        res = Oj.load(full_res.env[:body])
        res['data'].nil? ? res : res['data']
        return res
      else
        msg = "POST #{full_res.env[:url]} (status: #{full_res.env[:status]})"
        msg += "\n\tERROR: #{full_res.env[:body]}"
        raise msg
      end
    end

    def put(resource, data='')
      puts " ----------- " if @debug
      puts "PUT #{resource} / #{Oj.dump(data)}" if @debug
      full_res = self.conn.put(resource, Oj.dump(data))
      ap full_res.env if @debug
      res = Oj.load(full_res.env[:body])
      res['data'].nil? ? res : res['data']
    end

    def delete(resource)
      puts " ----------- " if @debug
      puts "DELETE #{resource}" if @debug
      full_res = self.conn.delete(resource)
      ap full_res.env if @debug
      (200 == full_res.env[:status]) ? "" : eval(full_res.env[:body])
    end

  end

end
