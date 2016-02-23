module TogglV8
  class API

    ##
    # ---------
    # :section: Tasks
    #
    # NOTE: Tasks are available only for pro workspaces.
    #
    # name              : The name of the task (string, required, unique in project)
    # pid               : project ID for the task (integer, required)
    # wid               : workspace ID, where the task will be saved
    #                     (integer, project's workspace id is used when not supplied)
    # uid               : user ID, to whom the task is assigned to (integer, not required)
    # estimated_seconds : estimated duration of task in seconds (integer, not required)
    # active            : whether the task is done or not (boolean, by default true)
    # at                : timestamp that is sent in the response for PUT, indicates the time task was last updated
    # -- Additional fields --
    # done_seconds      : duration (in seconds) of all the time entries registered for this task
    # uname             : full name of the person to whom the task is assigned to

    def create_task(params)
      requireParams(params, ['name', 'pid'])
      post "tasks", { 'task' => params }
    end

    def get_task(task_id)
      get "tasks/#{task_id}"
    end

    # ex: update_task(1894675, { :active => true, :estimated_seconds => 4500, :fields => "done_seconds,uname"})
    def update_task(task_id, params)
      put "tasks/#{task_id}", { 'task' => params }
    end

    def delete_task(task_id)
      delete "tasks/#{task_id}"
    end

    # ------------ #
    # Mass Actions #
    # ------------ #

    def update_tasks(task_ids, params)
      return if task_ids.nil?
      put "tasks/#{task_ids.join(',')}", { 'task' => params }
    end

    def delete_tasks(task_ids)
      return if task_ids.nil?
      delete "tasks/#{task_ids.join(',')}"
    end

  end
end
