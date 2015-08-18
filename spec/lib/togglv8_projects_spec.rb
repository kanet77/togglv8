require_relative '../../lib/togglv8'
require 'oj'

describe "Projects" do
  before :all do
    @toggl = Toggl::V8.new(Testing::TEST_API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
  end

  it 'receives {} if there are no workspace projects' do
    project = @toggl.projects(@workspace_id)
    expect(project).to be {}
  end

  context 'new project' do
    before :each do
      @project = @toggl.create_project({ name: 'project1', wid: @workspace_id })
    end

    after :each do
      @toggl.delete_project(@project['id'])
    end

    it 'creates a project' do
      expect(@project).to_not be nil
      expect(@project['name']).to eq 'project1'
      expect(@project['billable']).to eq false
      expect(@project['is_private']).to eq true
      expect(@project['active']).to eq true
      expect(@project['template']).to eq false
      expect(@project['auto_estimates']).to eq false
      expect(@project['wid']).to eq @workspace_id
    end

    it 'gets project data' do
      p = @toggl.get_project(@project['id'])
      expect(p).to_not be nil
      expect(p['name']).to eq 'project1'
      expect(p['billable']).to eq false
      expect(p['is_private']).to eq true
      expect(p['active']).to eq true
      expect(p['template']).to eq false
      expect(p['auto_estimates']).to eq false
      expect(p['wid']).to eq @workspace_id
    end

    it 'updates project data' do
      new_values = {
        'name' => 'PROJECT-X',
        'is_private' => false,
        'active' => false,
        'auto_estimates' => true,
      }

      p = @toggl.update_project(@project['id'], new_values)

      expect(p).to include(new_values)
    end

    it 'updates Pro project data' do
      pending('Pro features') unless Testing::PRO_ACCOUNT

      expected = {
        template: true,
        billable: true,
      }
      p = @toggl.update_project(@project['id'], expected)
      expect(p).to include(expected)
    end
  end

  context 'project users' do
    xit 'gets {} if there are no project users' do
    end

    xit 'gets project users' do
    end
  end

  context 'project tasks' do
    xit 'gets {} if there are no project tasks' do
    end

    xit 'gets project tasks' do
    end
  end

  it 'deletes multiple projects' do
    # start with no projects
    expect(@toggl.projects(@workspace_id)).to be {}

    p1 = @toggl.create_project({ name: 'p1', wid: @workspace_id })
    p2 = @toggl.create_project({ name: 'p2', wid: @workspace_id })
    p3 = @toggl.create_project({ name: 'p3', wid: @workspace_id })

    # see 3 new projects
    expect(@toggl.projects(@workspace_id).length).to eq 3

    p_ids = [p1, p2, p3].map { |p| p['id']}
    @toggl.delete_projects(p_ids)

    # end with no projects
    expect(@toggl.projects(@workspace_id)).to be {}
  end
end