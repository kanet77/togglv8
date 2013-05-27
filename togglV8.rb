#! /usr/bin/env rvm ruby-1.9.3-head do ruby

require 'rubygems'
require 'faraday'
require 'awesome_print'
require 'json'

class Toggl
  attr_accessor :conn

  def initialize(username=nil, password='api_token')
    self.conn = Faraday.new(url: 'https://www.toggl.com/api/v8')
    self.conn.headers = {"Content-Type" => "application/json"}
    # self.conn.response :json, :content_type => /\bjson$/
    # self.conn.response :logger
    if (password.to_s == 'api_token' && username.to_s == '')
      toggl_api_file = ENV['HOME']+'/.toggl'
      if FileTest.exist?(toggl_api_file) then
        username = IO.read(toggl_api_file)
      else
        raise "Expecting api_token in file ~/.toggl or parameters (api_token) or (username, password)"
      end
    end
    self.conn.basic_auth username, password
  end

#----------#
#--- Me ---#
#----------#

  def me(all=false)
    res = get "me%s" %  [all ? '?with_related_data=true'  : '']
    # puts res.code
  end

#------------------#
#--- Workspaces ---#
#------------------#

  def workspaces
    res = get "workspaces"
    # puts res.code
  end

#----------------#
#--- Projects ---#
#----------------#

  def projects(workspace)
    get "workspaces/#{workspace}/projects"
  end

  # def create_project(params={})
  #   my_post "projects", MultiJson.encode({:project => params})
  # end

#-------------#
#--- Tasks ---#
#-------------#

  def tasks(workspace)
    get "workspaces/#{workspace}/tasks"
  end

#-------------#
#--- Users ---#
#-------------#

  def users(workspace)
    get "workspaces/#{workspace}/users"
  end

#---------------#
#--- Clients ---#
#---------------#

  def workspace_clients(workspace)
    get "workspaces/#{workspace}/clients"
  end

  # def create_client(params={})
  #   my_post
  #   response = post '/clients', body: MultiJson.encode(client: params)
  #   puts response
  #   response['data'].nil? ? response : response['data']
  # end

  # def create_client(params={})
  #   my_post "clients", MultiJson.encode({:client => params})
  # end

# private
def get(path)
  res = self.conn.get(path)
  JSON.parse(res.env[:body])
end

#   def my_post(resource_name, data)
#     response = post("/#{resource_name}", :body => data)
#     # puts response.code
#     puts response.body, response.code, response.message, response.headers.inspect

#     # response[:data].nil? ? response : response[:data]
#   end

end