#! /usr/bin/env rvm ruby-1.9.3-head do ruby

require 'rubygems'
require 'httparty'
require 'awesome_print'

class Toggl
  include HTTParty
  base_uri 'www.toggl.com/api/v8'
  format :json

  def initialize(api_token)
    self.class.basic_auth api_token, 'api_token'
  end

  def me()
    self.class.get('/me')
  end
end

toggl_api_file = ENV['HOME']+'/.toggl'
if FileTest.exist?(toggl_api_file) then
  api_token = IO.read(toggl_api_file)
end

t = Toggl.new(api_token)
ap t.me