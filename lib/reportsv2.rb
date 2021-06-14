module TogglV8
  TOGGL_REPORTS_URL = 'https://api.track.toggl.com/reports/api/'

  class ReportsV2
    include TogglV8::Connection

    REPORTS_V2_URL = TOGGL_REPORTS_URL + 'v2/'

    attr_reader :conn

    attr_accessor :workspace_id

    def initialize(opts={})
      debug(false)

      @user_agent = TogglV8::NAME

      username = opts[:api_token]
      if username.nil?
        toggl_api_file = opts[:toggl_api_file] || File.join(Dir.home, TOGGL_FILE)
        if File.exist?(toggl_api_file) then
          username = IO.read(toggl_api_file)
        else
          raise "Expecting one of:\n" +
            " 1) api_token in file #{toggl_api_file}, or\n" +
            " 2) parameter: (toggl_api_file), or\n" +
            " 3) parameter: (api_token), or\n" +
            "\n\tSee https://github.com/kanet77/togglv8#togglv8reportsv2" +
            "\n\tand https://github.com/toggl/toggl_api_docs/blob/master/reports.md#authentication"
        end
      end

      @conn = TogglV8::Connection.open(username, API_TOKEN, REPORTS_V2_URL, opts)
    end

    ##
    # ---------
    # :section: Report
    #
    # The following parameters and filters can be used in all of the reports
    #
    # user_agent              : the name of this application so Toggl can get in touch
    #                           (string, *required*)
    # workspace_id            : The workspace whose data you want to access.
    #                           (integer, *required*)
    # since                   : ISO 8601 date (YYYY-MM-DD), by default until - 6 days.
    #                           (string)
    # until                   : ISO 8601 date (YYYY-MM-DD), by default today
    #                           (string)
    # billable                : possible values: yes/no/both, default both
    # client_ids              : client ids separated by a comma, 0 if you want to filter out time entries without a client
    # project_ids             : project ids separated by a comma, 0 if you want to filter out time entries without a project
    # user_ids                : user ids separated by a comma
    # members_of_group_ids    : group ids separated by a comma. This limits provided user_ids to the provided group members
    # or_members_of_group_ids : group ids separated by a comma. This extends provided user_ids with the provided group members
    # tag_ids                 : tag ids separated by a comma, 0 if you want to filter out time entries without a tag
    # task_ids                : task ids separated by a comma, 0 if you want to filter out time entries without a task
    # time_entry_ids          : time entry ids separated by a comma
    # description             : time entry description
    #                           (string)
    # without_description     : filters out the time entries which do not have a description ('(no description)')
    #                           (true/false)
    # order_field             : date/description/duration/user in detailed reports
    #                           title/duration/amount in summary reports
    #                           title/day1/day2/day3/day4/day5/day6/day7/week_total in weekly report
    # order_desc              : on for descending and off for ascending order
    #                           (on/off)
    # distinct_rates          : on/off, default off
    # rounding                : on/off, default off, rounds time according to workspace settings
    # display_hours           : decimal/minutes, display hours with minutes or as a decimal number, default minutes
    #
    # NB! Maximum date span (until - since) is one year.

    # extension can be one of ['.pdf', '.csv', '.xls']. Possibly others?
    def report(type, extension, params)
      raise "workspace_id is required" if @workspace_id.nil?
      get "#{type}#{extension}", {
        :'user_agent' => @user_agent,
        :'workspace_id' => @workspace_id,
      }.merge(params)
    end

    def weekly(extension='', params={})
      report('weekly', extension, params)
    end

    def details(extension='', params={})
      report('details', extension, params)
    end

    def summary(extension='', params={})
      report('summary', extension, params)
    end

    ##
    # ---------
    # :section: Write report to file
    #
    def write_report(filename)
      extension = File.extname(filename)
      report = yield(extension)
      File.open(filename, "wb") do |file|
        file.write(report)
      end
    end

    def write_weekly(filename, params={})
      write_report(filename) do |extension|
        weekly(extension, params)
      end
    end

    def write_details(filename, params={})
      write_report(filename) do |extension|
        details(extension, params)
      end
    end

    def write_summary(filename, params={})
      write_report(filename) do |extension|
        summary(extension, params)
      end
    end


    ##
    # ---------
    # :section: Miscellaneous information
    #
    def revision
      get "revision"
    end

    def index
      get "index"
    end

    def env
      get "env"
    end

    ##
    # ---------
    # :section: Project Dashboard
    #
    # Project dashboard returns at-a-glance information for a single project.
    # This feature is only available with Toggl pro.
    #
    # user_agent          : email, or other way to contact client application developer
    #                       (string, *required*)
    # workspace_id        : The workspace whose data you want to access
    #                       (integer, *required*)
    # project_id          : The project whose data you want to access
    #                       (integer, *required*)
    # page                : number of 'tasks_page' you want to fetch
    #                       (integer, optional)
    # order_field string  : name/assignee/duration/billable_amount/estimated_seconds
    # order_desc string   : on/off, on for descending and off for ascending order
    def project(project_id, params={})
      raise "workspace_id is required" if @workspace_id.nil?
      get "project", {
        :'user_agent' => @user_agent,
        :'workspace_id' => @workspace_id,
        :'project_id' => project_id,
      }.merge(params)
    end

    ##
    # ---------
    # :section: Error (for testing)
    #
    # excludes endpoints 'error500' and 'division_by_zero_error'
    def error400
      get "error400"
    end
  end
end
