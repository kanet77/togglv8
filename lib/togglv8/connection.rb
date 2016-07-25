require 'faraday'
require 'oj'

require_relative '../logging'

module TogglV8
  module Connection
    include Logging

    DELAY_SEC = 1
    MAX_RETRIES = 3

    API_TOKEN = 'api_token'
    TOGGL_FILE = '.toggl'

    def self.open(username=nil, password=API_TOKEN, url=nil, opts={})
      raise 'Missing URL' if url.nil?

      Faraday.new(:url => url, :ssl => {:verify => true}) do |faraday|
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
      # logger.debug(procs[:debug_output].call)
      full_resp = nil
      i = 0
      loop do
        i += 1
        full_resp = procs[:api_call].call
        logger.ap(full_resp.env, :debug)
        break if full_resp.status != 429 || i >= MAX_RETRIES
        sleep(DELAY_SEC)
      end

      raise full_resp.headers['warning'] if full_resp.headers['warning']
      raise "HTTP Status: #{full_resp.status}" unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      full_resp
    end

    def get(resource, params={})
      query_params = params.map { |k,v| "#{k}=#{v}" }.join('&')
      resource += "?#{query_params}" unless query_params.empty?
      resource.gsub!('+', '%2B')
      full_resp = _call_api(debug_output: lambda { "GET #{resource}" },
                  api_call: lambda { self.conn.get(resource) } )
      return {} if full_resp == {}
      begin
        resp = Oj.load(full_resp.body)
        return resp['data'] if resp.respond_to?(:has_key?) && resp.has_key?('data')
        return resp
      rescue Oj::ParseError
        return full_resp.body
      end
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
