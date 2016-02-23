module TogglV8
  class API

    ##
    # ---------
    # :section: Tags
    #
    # name : The name of the tag (string, required, unique in workspace)
    # wid  : workspace ID, where the tag will be used (integer, required)

    def create_tag(params)
      requireParams(params, ['name', 'wid'])
      post "tags", { 'tag' => params }
    end

    # ex: update_tag(12345, { :name => "same tame game" })
    def update_tag(tag_id, params)
      put "tags/#{tag_id}", { 'tag' => params }
    end

    def delete_tag(tag_id)
      delete "tags/#{tag_id}"
    end
  end
end
