module TogglV8
  class API

    ##
    # ---------
    # :section: Workspaces
    #
    # name    : (string, required)
    # premium : If it's a pro workspace or not.
    #           Shows if someone is paying for the workspace or not (boolean, not required)
    # at      : timestamp that is sent in the response, indicates the time item was last updated

    def workspaces
      get "workspaces"
    end

    def clients(workspace_id=nil)
      if workspace_id.nil?
        get "clients"
      else
        get "workspaces/#{workspace_id}/clients"
      end
    end

    def projects(workspace_id, params={})
      active = params.has_key?(:active) ? "?active=#{params[:active]}" : ""
      get "workspaces/#{workspace_id}/projects#{active}"
    end

    def users(workspace_id)
      get "workspaces/#{workspace_id}/users"
    end

    def tasks(workspace_id, params={})
      active = params.has_key?(:active) ? "?active=#{params[:active]}" : ""
      get "workspaces/#{workspace_id}/tasks#{active}"
    end

    def tags(workspace_id)
      get "workspaces/#{workspace_id}/tags"
    end

    def leave_workspace(workspace_id)
      delete "workspaces/#{workspace_id}/leave"
    end
  end
end
