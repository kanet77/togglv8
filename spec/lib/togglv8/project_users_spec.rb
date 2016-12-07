describe 'Project Users' do
  before :all do
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
    @project = @toggl.create_project({ 'name' => 'project', 'wid' => @workspace_id })
    @added_user_id = 2450739
  end

  it 'creates new project users' do
    begin
      params = { 'pid' => @project['id'], 'uid' => @added_user_id }
      new_project_user = @toggl.create_project_users(params)
      expect(new_project_user['pid']).to eq @project['id']
      expect(new_project_user['uid']).to eq @added_user_id
    ensure
      @toggl.delete_project_users(new_project_user['id'])
    end
  end

  after :all do
    TogglV8SpecHelper.delete_all_projects(@toggl)
    projects = @toggl.my_projects
    expect(projects).to be_empty
  end
end
