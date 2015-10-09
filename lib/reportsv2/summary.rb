module ReportsV2
  class API < TogglBaseApi

    def summary(workspace_id, params={})
      get_report('summary', workspace_id, params)
    end

  end
end