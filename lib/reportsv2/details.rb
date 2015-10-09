module ReportsV2
  class API < TogglBaseApi

    def details(workspace_id, params={})
      get_report('details', workspace_id, params)
    end

  end
end