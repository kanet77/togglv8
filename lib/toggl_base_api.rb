#! /usr/bin/env rvm ruby-1.9.3-head do ruby
# encoding: utf-8

class TogglBaseApi

  attr_reader :conn

  def self.toggl_api_url
    'https://www.toggl.com'
  end

  def self.api_token
    'api_token'
  end

  def self.toggl_file
    '.toggl'
  end

  def user_agent
    'api'
  end

  def initialize(username=nil, password=self.class.api_token, opts={})
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN

    if username.nil? && password == self.class.api_token
      toggl_api_file = File.join(Dir.home, self.class.toggl_file)
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

    @conn = self.class.connection(username, password, opts)
  end

  #---------------#
  #--- Private ---#
  #---------------#

  private

    attr_writer :conn

    def self.connection(username, password, opts={})
      Faraday.new(url: toggl_api_url, ssl: {verify: true}) do |faraday|
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

    def get(resource, full_response=false)
      @logger.debug("GET #{resource}")
      full_resp = self.conn.get(resource)
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429
      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      resp = Oj.load(full_resp.body)

      return resp['data'] if resp.respond_to?(:has_key?) && resp.has_key?('data') && !full_response
      resp
    end

    def post(resource, data='')
      @logger.debug("POST #{resource} / #{data}")
      full_resp = self.conn.post(resource, Oj.dump(data))
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429
      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      resp = Oj.load(full_resp.body)
      resp['data']
    end

    def put(resource, data='')
      @logger.debug("PUT #{resource} / #{data}")
      full_resp = self.conn.put(resource, Oj.dump(data))
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429
      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      resp = Oj.load(full_resp.body)
      resp['data']
    end

    def delete(resource)
      @logger.debug("DELETE #{resource}")
      full_resp = self.conn.delete(resource)
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429

      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      full_resp.body
    end

end