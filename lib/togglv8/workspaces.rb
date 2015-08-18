module Toggl
  class V8

    #------------------#
    #--- Workspaces ---#
    #------------------#

    # name    : (string, required)
    # premium : If it's a pro workspace or not. Shows if someone is paying for the workspace or not (boolean, not required)
    # at      : timestamp that is sent in the response, indicates the time item was last updated

    def workspaces
      get "workspaces"
    end

    def clients(workspace=nil)
      if workspace.nil?
        get "clients"
      else
        get "workspaces/#{workspace}/clients"
      end
    end

    def projects(workspace, params={})
      active = params.has_key?(:active) ? "?active=#{params[:active]}" : ""
      get "workspaces/#{workspace}/projects#{active}"
    end

    def users(workspace)
      get "workspaces/#{workspace}/users"
    end

    def tasks(workspace, params={})
      active = params.has_key?(:active) ? "?active=#{params[:active]}" : ""
      get "workspaces/#{workspace}/tasks#{active}"
    end
  end
end
