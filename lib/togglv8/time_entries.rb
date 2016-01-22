module TogglV8
  class API

    ##
    # ---------
    # :section: Time Entries
    #
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
      params['created_with'] = 'TogglV8' unless params.has_key?('created_with')
      requireParams(params, ['start', 'duration', 'created_with'])
      if !params.has_key?('wid') and !params.has_key?('pid') and !params.has_key?('tid') then
        raise ArgumentError, "one of params['wid'], params['pid'], params['tid'] is required"
      end
      post "time_entries", { 'time_entry' => params }
    end

    def start_time_entry(params)
      params['created_with'] = 'TogglV8' unless params.has_key?('created_with')
      if !params.has_key?('wid') and !params.has_key?('pid') and !params.has_key?('tid') then
        raise ArgumentError, "one of params['wid'], params['pid'], params['tid'] is required"
      end
      post "time_entries/start", { 'time_entry' => params }
    end

    def stop_time_entry(time_entry_id)
      put "time_entries/#{time_entry_id}/stop", {}
    end

    def get_time_entry(time_entry_id)
      get "time_entries/#{time_entry_id}"
    end

    def get_current_time_entry
      get "time_entries/current"
    end

    def update_time_entry(time_entry_id, params)
      put "time_entries/#{time_entry_id}", { 'time_entry' => params }
    end

    def delete_time_entry(time_entry_id)
      delete "time_entries/#{time_entry_id}"
    end

    def iso8601(timestamp)
      return nil if timestamp.nil?
      if timestamp.is_a?(DateTime) or timestamp.is_a?(Date)
        formatted_ts = timestamp.iso8601
      elsif timestamp.is_a?(String)
        formatted_ts = DateTime.parse(timestamp).iso8601
      else
        raise ArgumentError, "Can't convert #{timestamp.class} to ISO-8601 Date/Time"
      end
      return formatted_ts.sub('+00:00', 'Z')
    end

    def get_time_entries(dates = {})
      start_date = dates[:start_date]
      end_date = dates[:end_date]
      params = []
      params.push("start_date=#{iso8601(start_date)}") unless start_date.nil?
      params.push("end_date=#{iso8601(end_date)}") unless end_date.nil?
      get "time_entries%s" % [params.empty? ? "" : "?#{params.join('&')}"]
    end

    # Example params: {'tags' =>['billed','productive'], 'tag_action' => 'add'}
    # tag_action can be 'add' or 'remove'
    def update_time_entries_tags(time_entry_ids, params)
      return if time_entry_ids.nil?
      requireParams(params, ['tags', 'tag_action'])
      put "time_entries/#{time_entry_ids.join(',')}", { 'time_entry' => params }
    end
  end
end