module Toggl
  class V8

    #----------------#
    #--- Projects ---#
    #----------------#

    # name        : The name of the project (string, required, unique for client and workspace)
    # wid         : workspace ID, where the project will be saved (integer, required)
    # cid         : client ID(integer, not required)
    # active      : whether the project is archived or not (boolean, by default true)
    # is_private  : whether project is accessible for only project users or for all workspace users (boolean, default true)
    # template    : whether the project can be used as a template (boolean, not required)
    # template_id : id of the template project used on current project's creation
    # billable    : whether the project is billable or not (boolean, default true, available only for pro workspaces)
    # at          : timestamp that is sent in the response for PUT, indicates the time task was last updated
    # -- Undocumented --
    # color       : number (in the range 0-23?)

    def create_project(params)
      requireParams(params, [:name, :wid])
      post "projects", {project: params}
    end

    def get_project(project_id)
      get "projects/#{project_id}"
    end

    def update_project(project_id, params)
      put "projects/#{project_id}", {project: params}
    end

    def get_project_users(project_id)
      get "projects/#{project_id}/project_users"
    end
  end
end
