describe 'Groups' do
  before :all do
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
  end

  context 'new group' do
    before :all do
      @group = @toggl.create_group({
        'name' => 'group 1',
        'wid' => @workspace_id,
      })
      group_ids = @toggl.groups(@workspace_id).map { |g| g['id'] }
      expect(group_ids).to eq [ @group['id'] ]
    end

    after :all do
      TogglV8SpecHelper.delete_all_groups(@toggl)
      groups = @toggl.groups(@workspace_id)
      expect(groups).to be_empty
    end

    it 'creates a group' do
      expect(@group).to_not be nil
      expect(@group['name']).to eq 'group 1'
      expect(@group['wid']).to eq @workspace_id
    end

    it 'returns group associated with workspace_id' do
      groups = @toggl.groups(@workspace_id)
      expect(groups).not_to be_empty
      expect(groups.first['name']).to eq 'group 1'
      expect(groups.first['wid']).to eq @workspace_id
    end
  end

  context 'updated group' do
    before :each do
      @group = @toggl.create_group({ 'name' => 'group to update', 'wid' => @workspace_id })
    end

    after :each do
      @toggl.delete_group(@group['id'])
    end

    it 'updates group data' do
      new_values = {
        'name' => 'group 2',
      }

      group = @toggl.update_group(@group['id'], new_values)
      expect(group).to include(new_values)
    end
  end
end
