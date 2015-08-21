module TogglV8
  class API

    ##
    # ---------
    # :section: Dashboard
    #
    # See https://github.com/toggl/toggl_api_docs/blob/master/chapters/dashboard.md

    def dashboard(workspace_id)
      get "dashboard/#{workspace_id}"
    end
  end
end
