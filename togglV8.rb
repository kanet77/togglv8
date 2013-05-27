#! /usr/bin/env rvm ruby-1.9.3-head do ruby

require 'rubygems'
require 'awesome_print'

require 'faraday'
require 'faraday_middleware'
require 'json'

class Toggl
  attr_accessor :conn

  def initialize(username=nil, password='api_token')
    if (password.to_s == 'api_token' && username.to_s == '')
      toggl_api_file = ENV['HOME']+'/.toggl'
      if FileTest.exist?(toggl_api_file) then
        username = IO.read(toggl_api_file)
      else
        raise "Expecting api_token in file ~/.toggl or parameters (api_token) or (username, password)"
      end
    end

    self.conn = connection(username, password)
  end

  def connection(username, password)
    conn = Faraday.new(url: 'https://www.toggl.com/api/v8')
    conn.headers = {"Content-Type" => "application/json"}
    conn.basic_auth username, password
    conn
  end

#--- Me ---#

  def me(all=false)
    res = get "me%s" %  [all ? '?with_related_data=true'  : '']
  end

#--- Workspaces ---#

  def workspaces
    res = get "workspaces"
    # puts res.code
  end

#--- Projects ---#

  def projects(workspace)
    get "workspaces/#{workspace}/projects"
  end

  def create_project(params={})
    post "projects", JSON.generate({:project => params})
  end

#--- Tasks ---#

  def tasks(workspace)
    get "workspaces/#{workspace}/tasks"
  end

  def create_task(params={})
    post "tasks", JSON.generate({:task => params})
  end

#--- Users ---#

  def users(workspace)
    get "workspaces/#{workspace}/users"
  end

#--- Clients ---#

  def workspace_clients(workspace)
    get "workspaces/#{workspace}/clients"
  end

#--- Private ---#

  private

  def get(path)
    res = self.conn.get(path)
    JSON.parse(res.env[:body])
  end

  def post(path, data)
    puts path + "," + data
    res = self.conn.post(path, data)
    JSON.parse(res.env[:body])
  end

end