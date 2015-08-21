describe 'Tasks', :pro_account do
  before :all do
    sleep(0.5)
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
    @project = @toggl.create_project({ name: 'project with a task', wid: @workspace_id })
  end

  after :all do
    @toggl.delete_project(@project['id'])
  end

  context 'new task' do
    before :all do
      sleep(0.5)
      @task = @toggl.create_task({ name: 'new task', pid: @project['id'] })
      task_ids = @toggl.get_project_tasks(@project['id']).map { |t| t['id'] }
      expect(task_ids).to eq [ @task['id'] ]
    end

    after :all do
      TogglV8SpecHelper.delete_all_tasks(@toggl)
      tasks = @toggl.get_project_tasks(@project['id'])
      expect(tasks).to be_empty
    end

    it 'creates a task' do
      expect(@task).to_not be nil
      expect(@task['name']).to eq 'new task'
      expect(@task['pid']).to eq @project['id']
      expect(@task['wid']).to eq @workspace_id
      expect(@task['active']).to eq true
    end

    it 'gets a task' do
      task = @toggl.get_task(@task['id'])
      expect(task).to eq @task
    end
  end

  context 'updated task' do
    before :each do
      @task = @toggl.create_task({ name: 'task to update', pid: @project['id'] })
    end

    after :each do
      @toggl.delete_task(@task['id'])
    end

    it 'updates task data' do
      new_values = {
        'name' => 'task-NEW',
      }

      task = @toggl.update_task(@task['id'], new_values)
      expect(task).to include(new_values)
    end
  end

  context 'multiple tasks' do
    before :each do
      sleep(0.5)
      @task1 = @toggl.create_task({ name: 'task1', pid: @project['id'] })
      @task2 = @toggl.create_task({ name: 'task2', pid: @project['id'] })
      @task3 = @toggl.create_task({ name: 'task3', pid: @project['id'] })
    end

    after :all do
      TogglV8SpecHelper.delete_all_tasks(@toggl)
    end

    it 'updates multiple tasks' do
      # start with 3 active tasks
      tasks = @toggl.get_project_tasks(@project['id'])
      active_flags = tasks.map { |t| t['active'] }
      expect().to match_array(['true', 'true', 'true'])

      t_ids = [@task1, @task2, @task3].map { |t| t['id'] }
      params = { 'active': true }
      @toggl.update_tasks(t_ids, params)

      # end with 3 inactive tasks
      tasks = @toggl.get_project_tasks(@project['id'])
      active_flags = tasks.map { |t| t['active'] }
      expect().to match_array(['true', 'true', 'true'])
    end

    it 'deletes multiple tasks' do
      # start with 3 new tasks
      expect(@toggl.get_project_tasks(@project['id']).length).to eq 3

      t_ids = [@task1, @task2, @task3].map { |t| t['id'] }
      @toggl.delete_tasks(t_ids)

      # end with no tasks
      expect(@toggl.get_project_tasks(@project['id']).length).to be_empty
    end
  end
end