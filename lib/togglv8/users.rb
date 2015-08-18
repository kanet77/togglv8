module Toggl
  class V8

    def me(all=nil)
      # TODO: Reconcile this with get_client_projects
      res = get "me%s" % [all.nil? ? "" : "?with_related_data=#{all}"]
    end

    def my_clients(user)
      user['projects']
    end

    def my_projects(user)
      user['projects']
    end

    def my_tags(user)
      user['tags']
    end

    def my_time_entries(user)
      user['time_entries']
    end

    def my_workspaces(user)
      user['workspaces']
    end
  end
end