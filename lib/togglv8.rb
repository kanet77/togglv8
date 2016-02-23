require 'faraday'
require 'oj'

require 'logger'
require 'awesome_print' # for debug output

require_relative 'togglv8/clients'
require_relative 'togglv8/dashboard'
require_relative 'togglv8/project_users'
require_relative 'togglv8/projects'
require_relative 'togglv8/tags'
require_relative 'togglv8/tasks'
require_relative 'togglv8/time_entries'
require_relative 'togglv8/users'
require_relative 'togglv8/version'
require_relative 'togglv8/workspaces'

# :mode => :compat will convert symbols to strings
Oj.default_options = { :mode => :compat }

module TogglV8
  TOGGL_API_URL = 'https://www.toggl.com/api/'
  DELAY_SEC = 1
  MAX_RETRIES = 3

  class API
    TOGGL_API_V8_URL = TOGGL_API_URL + 'v8/'
    API_TOKEN = 'api_token'
    TOGGL_FILE = '.toggl'

    attr_reader :conn

    def initialize(username=nil, password=API_TOKEN, opts={})
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN

      if username.nil? && password == API_TOKEN
        toggl_api_file = File.join(Dir.home, TOGGL_FILE)
        if FileTest.exist?(toggl_api_file) then
          username = IO.read(toggl_api_file)
        else
          raise "Expecting\n" +
            " 1) api_token in file #{toggl_api_file}, or\n" +
            " 2) parameter: (api_token), or\n" +
            " 3) parameters: (username, password).\n" +
            "\n\tSee https://github.com/toggl/toggl_api_docs/blob/master/chapters/authentication.md"
        end
      end

      @conn = TogglV8::API.connection(username, password, opts)
    end

    def debug(debug=true)
      if debug
        @logger.level = Logger::DEBUG
      else
        @logger.level = Logger::WARN
      end
    end

  #---------#
  # Private #
  #---------#

  private

    attr_writer :conn

    def self.connection(username, password, opts={})
      Faraday.new(:url => TOGGL_API_V8_URL, :ssl => {:verify => true}) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger, Logger.new('faraday.log') if opts[:log]
        faraday.adapter Faraday.default_adapter
        faraday.headers = { "Content-Type" => "application/json" }
        faraday.basic_auth username, password
      end
    end

    def requireParams(params, fields=[])
      raise ArgumentError, 'params is not a Hash' unless params.is_a? Hash
      return if fields.empty?
      errors = []
      for f in fields
        errors.push("params[#{f}] is required") unless params.has_key?(f)
      end
      raise ArgumentError, errors.join(', ') if !errors.empty?
    end

    def _call_api(procs)
      @logger.debug(procs[:debug_output].call)
      full_resp = nil
      i = 0
      loop do
        i += 1
        full_resp = procs[:api_call].call
        @logger.ap(full_resp.env, :debug)
        break if full_resp.status != 429 || i >= MAX_RETRIES
        sleep(DELAY_SEC)
      end

      raise "HTTP Status: #{full_resp.status}" unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      full_resp
    end

    def get(resource)
      resource.gsub!('+', '%2B')
      full_resp = _call_api(debug_output: lambda { "GET #{resource}" },
                            api_call: lambda { self.conn.get(resource) } )
      return {} if full_resp == {}
      resp = Oj.load(full_resp.body)
      return resp['data'] if resp.respond_to?(:has_key?) && resp.has_key?('data')
      resp
    end

    def post(resource, data='')
      resource.gsub!('+', '%2B')
      full_resp = _call_api(debug_output: lambda { "POST #{resource} / #{data}" },
                            api_call: lambda { self.conn.post(resource, Oj.dump(data)) } )
      return {} if full_resp == {}
      resp = Oj.load(full_resp.body)
      resp['data']
    end

    def put(resource, data='')
      resource.gsub!('+', '%2B')
      full_resp = _call_api(debug_output: lambda { "PUT #{resource} / #{data}" },
                            api_call: lambda { self.conn.put(resource, Oj.dump(data)) } )
      return {} if full_resp == {}
      resp = Oj.load(full_resp.body)
      resp['data']
    end

    def delete(resource)
      resource.gsub!('+', '%2B')
      full_resp = _call_api(debug_output: lambda { "DELETE #{resource}" },
                            api_call: lambda { self.conn.delete(resource) } )
      return {} if full_resp == {}
      full_resp.body
    end

  end
end
