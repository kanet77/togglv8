#! /usr/bin/env rvm ruby-1.9.3-head do ruby

require 'rubygems'
require 'httparty'
require 'awesome_print'

class Toggl
  include HTTParty
  base_uri 'www.toggl.com/api/v8'
  format :json
  headers "Content-Type" => "application/json"

  def initialize(username=nil, password='api_token')
    # self.class.default_params output: 'json'
    if (password.to_s == 'api_token' && username.to_s == '')
      toggl_api_file = ENV['HOME']+'/.toggl'
      if FileTest.exist?(toggl_api_file) then
        username = IO.read(toggl_api_file)
      else
        raise "Expecting api_token in file ~/.toggl or parameters (api_token) or (username, password)"
      end
    end
    self.class.basic_auth username, password
  end

  def debug(debug=true)
    self.class.debug_output if debug
  end

#----------#
#--- Me ---#
#----------#

  def me(all=false)
    res = self.class.get '/me%s' %  [all ? '?with_related_data=true'  : '']
  end

#------------------#
#--- Workspaces ---#
#------------------#

  def workspaces
    self.class.get "/workspaces"
  end

#----------------#
#--- Projects ---#
#----------------#

  def projects(workspace)
    self.class.get "/workspaces/#{workspace}/projects"
  end

  # def create_project(params={})
  #   my_post "projects", MultiJson.encode({:project => params})
  # end

#-------------#
#--- Tasks ---#
#-------------#

  def tasks(workspace)
    self.class.get "/workspaces/#{workspace}/tasks"
  end

#-------------#
#--- Users ---#
#-------------#

  def users(workspace)
    self.class.get "/workspaces/#{workspace}/users"
  end

#---------------#
#--- Clients ---#
#---------------#

  def workspace_clients(workspace)
    self.class.get "/workspaces/#{workspace}/clients"
  end

  # def create_client(params={})
  #   my_post
  #   response = self.class.post '/clients', body: MultiJson.encode(client: params)
  #   puts response
  #   response['data'].nil? ? response : response['data']
  # end

  # def create_client(params={})
  #   my_post "clients", MultiJson.encode({:client => params})
  # end

# private

#   def my_post(resource_name, data)
#     response = self.class.post("/#{resource_name}", :body => data)
#     # puts response.code
#     puts response.body, response.code, response.message, response.headers.inspect

#     # response[:data].nil? ? response : response[:data]
#   end

end