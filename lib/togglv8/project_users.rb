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

    def create_project_user(params)
      requireParams(params, ['pid', 'uid'])
      params[:fields] = "fullname"  # for simplicity, always request fullname field
      post "project_users", { 'project_user' => params }
    end

    def update_project_user(project_user_id, params)
      params[:fields] = "fullname"  # for simplicity, always request fullname field
      put "project_users/#{project_user_id}", { 'project_user' => params }
    end

    def delete_project_user(project_user_id)
      delete "project_users/#{project_user_id}"
    end
  end
end
