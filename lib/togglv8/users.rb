module Toggl
  class V8

    def me(all=nil)
      # TODO: Reconcile this with get_client_projects
      @user = get "me%s" % [all.nil? ? "" : "?with_related_data=#{all}"]
      return @user
    end

    def my_clients(user=nil)
      user = me(all=true) if user.nil?
      user['projects']
    end

    def my_projects(user=nil)
      user = me(all=true) if user.nil?
      user['projects']
    end

    def my_tags(user=nil)
      user = me(all=true) if user.nil?
      user['tags']
    end

    def my_time_entries(user=nil)
      user = me(all=true) if user.nil?
      user['time_entries']
    end

    def my_workspaces(user=nil)
      user = me(all=true) if user.nil?
      user['workspaces']
    end
  end
end