require 'faraday'
require 'oj'

require 'logger'
require 'awesome_print' # for debug output

require_relative 'reportsv2/summary'
require_relative 'reportsv2/details'
require_relative 'reportsv2/weekly'

require_relative 'toggl_base_api'


# mode: :compat will convert symbols to strings
Oj.default_options = { mode: :compat }

module ReportsV2
  TOGGL_API_BASE_URL = 'https://www.toggl.com/reports/api/'

  class API
    attr_accessor :user_agent

    # Because reports can contain information outside of the 'data' field
    # We need to explicitly request the full response for reports
    FULL_RESPONSE = true

    def self.toggl_api_url
      TOGGL_API_BASE_URL + 'v2/'
    end

    def user_agent
      @user_agent || super
    end

    def get_report(report_type, workspace_id, params={})
      params_string = params.map do |key, value|
        if value.is_a? Array
          value = value.join('%')
        end
        "#{key}=#{value}"
      end.join('&')
      get "#{report_type}?user_agent=#{user_agent}&workspace_id=#{workspace_id}&#{params_string}", FULL_RESPONSE
    end
  end

end