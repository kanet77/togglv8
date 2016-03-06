module TogglV8
  TOGGL_REPORTS_URL = 'https://toggl.com/reports/api'

  class ReportsV2
    include TogglV8::Connection

    REPORTS_V2_URL = TOGGL_REPORTS_URL + 'v2/'

    attr_reader :conn

    def initialize(username=nil, password=API_TOKEN, opts={})
      @conn = TogglV8::TogglConn.connection(username, password,
                REPORTS_V2_URL, opts)
    end
  end
end
