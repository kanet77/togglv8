module TogglV8
  class API

    ##
    # ---------
    # :section: Groups
    #
    # name : The name of the group (string, required)
    # wid  : workspace ID, where the group will be used (integer, required)
    # at   : timestamp that is sent in the response, indicates the time group was last updated
    #
    # See https://github.com/toggl/toggl_api_docs/blob/master/chapters/groups.md

    def create_group(params)
      requireParams(params, ['name', 'wid'])
      post "groups", { 'group' => params }
    end

    def update_group(group_id, params)
      put "groups/#{group_id}", { 'group' => params }
    end

    def delete_group(group_id)
      delete "groups/#{group_id}"
    end
  end
end
