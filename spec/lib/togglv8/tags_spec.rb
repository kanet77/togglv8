describe 'Tags' do
  before :all do
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
  end

  context 'new tag' do
    before :all do
      @tag = @toggl.create_tag({ 'name' => 'new tag +1', 'wid' => @workspace_id })
      tag_ids = @toggl.my_tags.map { |t| t['id'] }
      expect(tag_ids).to eq [ @tag['id'] ]
    end

    after :all do
      TogglV8SpecHelper.delete_all_tags(@toggl)
      tags = @toggl.my_tags
      expect(tags).to be_empty
    end

    it 'creates a tag' do
      expect(@tag).to_not be nil
      expect(@tag['name']).to eq 'new tag +1'
      expect(@tag['notes']).to eq nil
      expect(@tag['wid']).to eq @workspace_id
    end

    it 'returns tag associated with workspace_id' do
      tags = @toggl.tags(@workspace_id)
      expect(tags).not_to be_empty
      expect(tags.first['name']).to eq 'new tag +1'
      expect(tags.first['wid']).to eq @workspace_id
    end
  end

  context 'updated tag' do
    before :each do
      @tag = @toggl.create_tag({ 'name' => 'tag to update', 'wid' => @workspace_id })
    end

    after :each do
      @toggl.delete_tag(@tag['id'])
    end

    it 'updates tag data' do
      new_values = {
        'name' => 'TAG-NEW',
      }

      tag = @toggl.update_tag(@tag['id'], new_values)
      expect(tag).to include(new_values)
    end
  end
end