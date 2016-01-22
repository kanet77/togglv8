describe 'Clients' do
  before :all do
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
  end

  it 'gets {} if there are no clients' do
    client = @toggl.clients
    expect(client).to be_empty
  end

  it 'gets {} if there are no workspace clients' do
    client = @toggl.clients(@workspace_id)
    expect(client).to be_empty
  end

  context 'new client' do
    before :all do
      @client = @toggl.create_client({ 'name' => 'new client +1', 'wid' => @workspace_id })
      client_ids = @toggl.my_clients.map { |c| c['id'] }
      expect(client_ids).to eq [ @client['id'] ]
    end

    after :all do
      TogglV8SpecHelper.delete_all_clients(@toggl)
      clients = @toggl.my_clients
      expect(clients).to be_empty
    end

    it 'gets a client' do
      client_ids = @toggl.clients.map { |c| c['id'] }
      expect(client_ids).to eq [ @client['id'] ]
    end

    it 'gets a workspace client' do
      client_ids = @toggl.clients(@workspace_id).map { |c| c['id'] }
      expect(client_ids).to eq [ @client['id'] ]
    end

    context 'multiple clients' do
      before :all do
        @client2 = @toggl.create_client({ 'name' => 'new client 2', 'wid' => @workspace_id })
      end

      after :all do
        @toggl.delete_client(@client2['id'])
      end

      it 'gets clients' do
        client_ids = @toggl.clients.map { |c| c['id'] }
        expect(client_ids).to match_array [ @client['id'], @client2['id'] ]
      end

      it 'gets workspace clients' do
        client_ids = @toggl.clients(@workspace_id).map { |c| c['id'] }
        expect(client_ids).to match_array [ @client['id'], @client2['id'] ]
      end
    end

    it 'creates a client' do
      expect(@client).to_not be nil
      expect(@client['name']).to eq 'new client +1'
      expect(@client['notes']).to eq nil
      expect(@client['wid']).to eq @workspace_id
    end

    it 'gets client data' do
      client = @toggl.get_client(@client['id'])
      expect(client).to_not be nil
      expect(client['name']).to eq @client['name']
      expect(client['wid']).to eq @client['wid']
      expect(client['notes']).to eq @client['notes']
      expect(client['at']).to_not be nil
    end

    context 'client projects' do
      it 'gets {} if there are no client projects' do
        projects = @toggl.get_client_projects(@client['id'])
        expect(projects).to be_empty
      end

      context 'new client projects' do
        before :all do
          @project = @toggl.create_project({ 'name' => 'project', 'wid' => @workspace_id, 'cid' => @client['id'] })
        end

        after :all do
          TogglV8SpecHelper.delete_all_projects(@toggl)
        end

        it 'gets a client project' do
          projects = @toggl.get_client_projects(@client['id'])
          project_ids = projects.map { |p| p['id'] }
          expect(project_ids).to eq [ @project['id'] ]
        end

        it 'gets multiple client projects' do
          project2 = @toggl.create_project({ 'name' => 'project2', 'wid' => @workspace_id, 'cid' => @client['id'] })

          projects = @toggl.get_client_projects(@client['id'])
          project_ids = projects.map { |p| p['id'] }
          expect(project_ids).to match_array [ @project['id'], project2['id'] ]

          @toggl.delete_project(project2['id'])
        end
      end
    end
  end

  context 'updated client' do
    before :each do
      @client = @toggl.create_client({ 'name' => 'client to update', 'wid' => @workspace_id })
    end

    after :each do
      @toggl.delete_client(@client['id'])
    end

    it 'updates client data' do
      new_values = {
        'name' => 'CLIENT-NEW',
        'notes' => 'NOTES-NEW',
      }

      client = @toggl.update_client(@client['id'], new_values)
      expect(client).to include(new_values)
    end

    # It appears hourly rate is no longer tied to a client despite the docs:
    # https://github.com/toggl/toggl_api_docs/blob/master/chapters/clients.md#clients
    xit 'updates Pro client data', :pro_account do
      new_values = {
        'hrate' => '7.77',
        'cur' => 'USD',
      }
      client = @toggl.update_client(@client['id'], new_values)

      client = @toggl.get_client(@client['id'])
      expect(client).to include(new_values)
    end
  end
end