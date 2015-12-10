module TogglV8
  class API

    ##
    # ---------
    # :section: Clients
    #
    # name  : The name of the client (string, required, unique in workspace)
    # wid   : workspace ID, where the client will be used (integer, required)
    # notes : Notes for the client (string, not required)
    # hrate : The hourly rate for this client (float, not required, available only for pro workspaces)
    # cur   : The name of the client's currency (string, not required, available only for pro workspaces)
    # at    : timestamp that is sent in the response, indicates the time client was last updated

    def create_client(params)
      requireParams(params, ['name', 'wid'])
      post "clients", { 'client' => params }
    end

    def get_client(client_id)
      get "clients/#{client_id}"
    end

    def update_client(client_id, params)
      put "clients/#{client_id}", { 'client' => params }
    end

    def delete_client(client_id)
      delete "clients/#{client_id}"
    end

    def get_client_projects(client_id, params={})
      active = params.has_key?('active') ? "?active=#{params['active']}" : ""
      get "clients/#{client_id}/projects#{active}"
    end
  end
end
