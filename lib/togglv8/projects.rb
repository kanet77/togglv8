module TogglV8
  class API

    ##
    # ---------
    # :section: Projects
    #
    # See Toggl {Projects}[https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md]
    #
    # name            : The name of the project
    #                     (string, *required*, unique for client and workspace)
    # wid             : workspace ID, where the project will be saved
    #                     (integer, *required*)
    # cid             : client ID
    #                     (integer, not required)
    # active          : whether the project is archived or not
    #                     (boolean, by default true)
    # is_private      : whether project is accessible for only project users or for all workspace users
    #                     (boolean, default true)
    # template        : whether the project can be used as a template
    #                     (boolean, not required)
    # template_id     : id of the template project used on current project's creation
    # billable        : whether the project is billable or not
    #                     (boolean, default true, available only for pro workspaces)
    # auto_estimates  : whether the estimated hours is calculated based on task estimations or is fixed manually
    #                   (boolean, default false, not required, premium functionality)
    # estimated_hours : if auto_estimates is true then the sum of task estimations is returned, otherwise user inserted hours
    #                     (integer, not required, premium functionality)
    # at              : timestamp that is sent in the response for PUT, indicates the time task was last updated
    # color           : id of the color selected for the project
    # rate            : hourly rate of the project
    #                     (float, not required, premium functionality)
    # created_at      : timestamp indicating when the project was created (UTC time), read-only
    # ---------

    ##
    # :category: Projects
    #
    # Public: Create a new project
    #
    # params - The Hash used to create the project (default: {})
    #          :name            - The name of the project (string, required, unique for client and workspace)
    #          :wid             - workspace ID, where the project will be saved (integer, required)
    #          :cid             - client ID (integer, not required)
    #          :active          - whether the project is archived or not (boolean, by default true)
    #          :is_private      - whether project is accessible for only project users or for all workspace users (boolean, default true)
    #          :template        - whether the project can be used as a template (boolean, not required)
    #          :template_id     - id of the template project used on current project's creation
    #          :billable        - whether the project is billable or not (boolean, default true, available only for pro workspaces)
    #          :auto_estimates  - whether the estimated hours is calculated based on task estimations or is fixed manually (boolean, default false, not required, premium functionality)
    #          :estimated_hours - if auto_estimates is true then the sum of task estimations is returned, otherwise user inserted hours (integer, not required, premium functionality)
    #          :at              - timestamp that is sent in the response for PUT, indicates the time task was last updated
    #          :color           - id of the color selected for the project
    #          :rate            - hourly rate of the project (float, not required, premium functionality)
    #          :created_at      - timestamp indicating when the project was created (UTC time), read-only
    #
    # Examples
    #
    #     toggl.create_project({ :name => 'My project', :wid => 1060392 })
    #     => {"id"=>10918774,
    #      "wid"=>1060392,
    #      "name"=>"project5",
    #      "billable"=>false,
    #      "is_private"=>true,
    #      "active"=>true,
    #      "template"=>false,
    #      "at"=>"2015-08-18T10:03:51+00:00",
    #      "color"=>"5",
    #      "auto_estimates"=>false}
    #
    # Returns a +Hash+ representing the newly created Project.
    #
    # See Toggl {Create Project}[https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#create-project]
    def create_project(params)
      requireParams(params, ['name', 'wid'])
      post "projects", { 'project' => params }
    end

    # [Get project data](https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#get-project-data)
    def get_project(project_id)
      get "projects/#{project_id}"
    end

    # [Update project data](https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#update-project-data)
    def update_project(project_id, params)
      put "projects/#{project_id}", { 'project' => params }
    end

    # [Delete a project](https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#delete-a-project)
    def delete_project(project_id)
      delete "projects/#{project_id}"
    end

    # [Get project users](https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#get-project-users)
    def get_project_users(project_id)
      get "projects/#{project_id}/project_users"
    end

    # [Get project tasks](https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#get-project-tasks)
    def get_project_tasks(project_id)
      get "projects/#{project_id}/tasks"
    end

    # [Get workspace projects](https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#get-workspace-projects)

    # [Delete multiple projects](https://github.com/toggl/toggl_api_docs/blob/master/chapters/projects.md#delete-multiple-projects)
    def delete_projects(project_ids)
      return if project_ids.nil?
      delete "projects/#{project_ids.join(',')}"
    end
  end
end
