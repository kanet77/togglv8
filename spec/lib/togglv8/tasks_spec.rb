describe 'Tasks', :pro_account do
  before :all do
    @toggl = TogglV8::API.new(Testing::API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
    @project = @toggl.create_project({ 'name' => 'project with a task', 'wid' => @workspace_id })
  end

  after :all do
    @toggl.delete_project(@project['id'])
  end

  context 'new task' do
    before :all do
      @task = @toggl.create_task({ 'name' => 'new task +1', 'pid' => @project['id'] })
      @task_ids = @toggl.get_project_tasks(@project['id']).map { |t| t['id'] }
      expect(@task_ids).to eq [ @task['id'] ]
    end

    after :all do
      @toggl.delete_tasks(@task_ids)
      tasks = @toggl.get_project_tasks(@project['id'])
      expect(tasks).to be_empty
    end

    it 'creates a task' do
      expect(@task).to_not be nil
      expect(@task['name']).to eq 'new task +1'
      expect(@task['pid']).to eq @project['id']
      expect(@task['wid']).to eq @workspace_id
      expect(@task['active']).to eq true
    end

    it 'gets a task' do
      task = @toggl.get_task(@task['id'])
      expect(task).to include('at') # 'at' is last updated timestamp
      task.delete('at')             # 'at' is not included in POST response
      expect(task).to eq @task      # compare POST and GET responses
    end
  end

  context 'updated task' do
    before :each do
      @task = @toggl.create_task({ 'name' => 'task to update', 'pid' => @project['id'] })
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
      timestamp = Time.now.strftime("%H%M%S.%9N")
      @task1 = @toggl.create_task({ 'name' => "task1-#{timestamp}", 'pid' => @project['id'] })
      @task2 = @toggl.create_task({ 'name' => "task2-#{timestamp}", 'pid' => @project['id'] })
      @task3 = @toggl.create_task({ 'name' => "task3-#{timestamp}", 'pid' => @project['id'] })
      @task_ids = [ @task1['id'], @task2['id'], @task3['id'] ]
    end

    after :all do
      @toggl.delete_tasks(@task_ids)
    end

    it 'updates multiple tasks' do
      # start with 3 active tasks
      tasks = @toggl.get_project_tasks(@project['id'])
      active_flags = tasks.map { |t| t['active'] }
      expect(active_flags).to match_array([true, true, true])

      t_ids = [@task1, @task2, @task3].map { |t| t['id'] }
      params = { 'active' => false }
      @toggl.update_tasks(t_ids, params)

      # end with no active tasks
      tasks = @toggl.get_project_tasks(@project['id'])
      expect(tasks).to be_empty
    end

    it 'deletes multiple tasks' do
      # start with 3 new tasks
      expect(@toggl.get_project_tasks(@project['id']).length).to eq 3

      t_ids = [@task1, @task2, @task3].map { |t| t['id'] }
      @toggl.delete_tasks(t_ids)

      # end with no active tasks
      expect(@toggl.get_project_tasks(@project['id'])).to be_empty
    end
  end
end