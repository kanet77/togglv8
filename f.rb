require 'rubygems'
require 'awesome_print'

require 'faraday'
require 'faraday_middleware'
require 'json'

def c
  conn = Faraday.new(url: 'https://www.toggl.com/api/v8')
  conn.headers = {"Content-Type" => "application/json"}
  conn.basic_auth `cat ~/.toggl`, 'api_token'
  conn
end

