require 'faraday'
require 'oj'

require 'logger'
require 'awesome_print' # for debug output

require_relative 'togglv8/clients'
require_relative 'togglv8/project_users'
require_relative 'togglv8/projects'
require_relative 'togglv8/tags'
require_relative 'togglv8/tasks'
require_relative 'togglv8/time_entries'
require_relative 'togglv8/users'
require_relative 'togglv8/version'
require_relative 'togglv8/workspaces'

# mode: :compat will convert symbols to strings
Oj.default_options = { mode: :compat }

module Toggl
  TOGGL_API_URL = 'https://www.toggl.com/api/'

  class V8
    TOGGL_API_V8_URL = TOGGL_API_URL + 'v8/'
    API_TOKEN = 'api_token'

    attr_reader :conn

    def initialize(username=nil, password=API_TOKEN, opts={})
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN

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

  #---------------#
  #--- Private ---#
  #---------------#

  private

    attr_writer :conn

    def self.connection(username, password, opts={})
      Faraday.new(url: TOGGL_API_V8_URL, ssl: {verify: true}) do |faraday|
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


    def get(resource)
      @logger.debug(" -----------")
      @logger.debug("GET #{resource}")
      full_resp = self.conn.get(resource)
      @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429
      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      resp = Oj.load(full_resp.body)

      return resp['data'] if resp.respond_to?(:has_key?) && resp.has_key?('data')
      resp
    end

    def post(resource, data='')
      @logger.debug(" ----------- ")
      @logger.debug("POST #{resource} / #{data}")
      full_res = self.conn.post(resource, Oj.dump(data))

      @logger.ap(full_res.env, :debug)
      if (200 == full_res.env[:status]) then
        res = Oj.load(full_res.env[:body])
        return res['data'].nil? ? res : res['data']
      else
        msg = "POST #{full_res.env[:url]} (status: #{full_res.env[:status]})"
        msg += "\n\tERROR: #{full_res.env[:body]}"
        raise msg
      end
    end

    def put(resource, data='')
      @logger.debug(" ----------- ")
      @logger.debug("PUT #{resource} / #{data}")

      full_res = self.conn.put(resource, Oj.dump(data))
      @logger.ap(full_res.env, :debug)

      res = Oj.load(full_res.env[:body])
      res['data'].nil? ? res : res['data']
    end

    def delete(resource)
      @logger.debug(" -----------")
      @logger.debug("DELETE #{resource}")
      full_resp = self.conn.delete(resource)
      @logger.ap(full_resp.env, :debug)

      raise Oj.dump(full_resp.env) unless full_resp.success?
      full_resp.body
    end

  end

end
