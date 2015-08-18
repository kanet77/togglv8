module Toggl
  class V8

    # https://github.com/toggl/toggl_api_docs/blob/master/chapters/time_entries.md
    #
    # description  : (string, strongly suggested to be used)
    # wid          : workspace ID (integer, required if pid or tid not supplied)
    # pid          : project ID (integer, not required)
    # tid          : task ID (integer, not required)
    # billable     : (boolean, not required, default false, available for pro workspaces)
    # start        : time entry start time (string, required, ISO 8601 date and time)
    # stop         : time entry stop time (string, not required, ISO 8601 date and time)
    # duration     : time entry duration in seconds. If the time entry is currently running,
    #                the duration attribute contains a negative value,
    #                denoting the start of the time entry in seconds since epoch (Jan 1 1970).
    #                The correct duration can be calculated as current_time + duration,
    #                where current_time is the current time in seconds since epoch. (integer, required)
    # created_with : the name of your client app (string, required)
    # tags         : a list of tag names (array of strings, not required)
    # duronly      : should Toggl show the start and stop time of this time entry? (boolean, not required)
    # at           : timestamp that is sent in the response, indicates the time item was last updated

    def create_time_entry(params)
      requireParams(params, [:description, :start, :duration, :created_with])
      if !params.has_key?(:wid) and !params.has_key?(:pid) and !params.has_key?(:tid) then
        raise ArgumentError, "one of params['wid'], params['pid'], params['tid'] is required"
      end
      post "time_entries", {time_entry: params}
    end

    def start_time_entry(params)
      if !params.has_key?(:wid) and !params.has_key?(:pid) and !params.has_key?(:tid) then
        raise ArgumentError, "one of params['wid'], params['pid'], params['tid'] is required"
      end
      post "time_entries/start", {time_entry: params}
    end

    def stop_time_entry(time_entry_id)
      put "time_entries/#{time_entry_id}/stop", {}
    end

    def get_time_entry(time_entry_id)
      get "time_entries/#{time_entry_id}"
    end

    def update_time_entry(time_entry_id, params)
      put "time_entries/#{time_entry_id}", {time_entry: params}
    end

    def delete_time_entry(time_entry_id)
      delete "time_entries/#{time_entry_id}"
    end

    def iso8601(date)
      return nil if date.nil?
      if date.is_a?(Time) or date.is_a?(Date)
        iso = date.iso8601
      elsif date.is_a?(String)
        iso =  DateTime.parse(date).iso8601
      else
        raise ArgumentError, "Can't convert #{date.class} to ISO-8601 Date/Time"
      end
      return Faraday::Utils.escape(iso)
    end

    def get_time_entries(start_date=nil, end_date=nil)
      params = []
      params.push("start_date=#{iso8601(start_date)}") if !start_date.nil?
      params.push("end_date=#{iso8601(end_date)}") if !end_date.nil?
      get "time_entries%s" % [params.empty? ? "" : "?#{params.join('&')}"]
    end
  end
end