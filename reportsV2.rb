#! /usr/bin/env rvm ruby-1.9.3-head do ruby
# encoding: utf-8

require 'rubygems'
require 'logger'
require 'faraday'
require 'json'
require_relative 'TogglCon'

require 'awesome_print' # for debug output

class TogglReports
  include TogglCon
  
  
  def initialize(username=nil, password='api_token', user_agent='api', debug=nil)
    self.debug_on(debug) if !debug.nil?
    if (password.to_s == 'api_token' && username.to_s == '')
      toggl_api_file = ENV['HOME']+'/.toggl'
      if FileTest.exist?(toggl_api_file) then
        username = IO.read(toggl_api_file)
      else
        raise SystemCallError, "Expecting api_token in file ~/.toggl or parameters (api_token) or (username, password)"
      end
    end
    
    @api = 'https://www.toggl.com/reports/api/v2/'
    @user_agent = user_agent
    @conn = connection(username, password, @api)
  end

  # some params that can be used
  # since       : date entry start date - yyy-mm-dd
  # untill      : date entry end date - yyy-mm-dd
  # billable    : boolean
  # client_ids  : array of client_id
  # project_ids : array of project_id
  # tag_ids     : array of tag_ids
  # user_ids    : array of user_ids
  

  #---------------#
  #--- Summary ---#
  #---------------#

  # additional summary parameters
  # grouping    : projects/clients/users
  # subgrouping : projects\time_entries projects\tasks projects\users
  #             : clinets\time_entries clients\tasks clients\projects clients\users
  #             : users\time_entries users\tasks users\projects users\clients
  # subgrouping_ids : (boolean) whether returned items will contain 'ids' key containing coma separated group item ID values
  # grouped_time_entry_ids : (boolean) whether returned items will contain 'time_entry_ids' key containing coma separated time entries ID values for given item
  
  def summary(workspace_id, params={})
    get_report('summary', workspace_id, params)
  end

  #---------------#
  #--- Details---#
  #---------------#

  def details(workspace_id, params={})
    get_report('details', workspace_id, params)
  end

  #---------------#
  #--- Weekly ----#
  #---------------#

  # additional weekly parameters
  # calculate : time/earnings
  # grouping  : just like the summary...
  # does not have an 'untill' params. will calc 7 days after 'since'

  def weekly(workspace_id, params={})
    get_report('weekly', workspace_id, params)
  end

  private

  def get_report(report_type, workspace_id, params={})
    params_string = params.map do |key, value| 
      if value.is_a? Array
        value = value.join('%')
      end
      "#{key}=#{value}" 
    end.join('&')
    get "#{report_type}?user_agent=#{@user_agent}&workspace_id=#{workspace_id}&#{params_string}"
  end
end