module ReportsV2
  class API < TogglBaseApi

    def weekly(workspace_id, params={})
      get_report('weekly', workspace_id, params)
    end

  end
end