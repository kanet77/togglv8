module TogglV8
  class API

    ##
    # ---------
    # :section: Project Users
    #
    # pid      : project ID (integer, required)
    # uid      : user ID, who is added to the project (integer, required)
    # wid      : workspace ID, where the project belongs to (integer, not-required, project's workspace id is used)
    # manager  : admin rights for this project (boolean, default false)
    # rate     : hourly rate for the project user (float, not-required, only for pro workspaces) in the currency of the project's client or in workspace default currency.
    # at       : timestamp that is sent in the response, indicates when the project user was last updated
    # -- Additional fields --
    # fullname : full name of the user, who is added to the project

    # uid can be a comma-separated list of user ids
    def create_project_users(params)
      requireParams(params, ['pid', 'uid'])
      params[:fields] = "fullname"  # for simplicity, always request fullname field
      post "project_users", { 'project_user' => params }
    end

    # uid can be a comma-separated list of user ids
    def update_project_users(params)
      params[:fields] = "fullname"  # for simplicity, always request fullname field
      put "project_users/#{project_user_id}", { 'project_user' => params }
    end

    # project_user_ids can be a comma-separated list of user ids
    def delete_project_users(project_user_ids)
      delete "project_users/#{project_user_ids}"
    end

    # does not support fields parameter
    def get_workspace_project_users(workspace_id)
      get "workspaces/#{workspace_id}/project_users"
    end

    # -- Deprecated -- (retained for backward compatibilty)

    # Deprecated in favor of create_project_users
    def create_project_user(params)
      create_project_users(params)
    end


    # Deprecated in favor of update_project_users
    def update_project_user(project_user_id, params)
      update_project_users(params)
    end


    # Deprecated in favor of delete_project_users
    def delete_project_user(project_user_id)
      delete_project_users(project_user_id)
    end
  end
end
