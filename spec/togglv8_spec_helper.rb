require_relative '../lib/togglv8'
require 'logger'

class TogglV8SpecHelper
  @logger = Logger.new(STDOUT)

  def self.setUp()
    toggl = Toggl::V8.new(Testing::TEST_API_TOKEN)
    user = toggl.me(all=true)
    default_workspace_id = user['default_wid']

    clients = toggl.my_clients(user)
    unless clients.nil?
      client_ids ||= clients.map { |c| c['id'] }
      client_ids.each do |c_id|
        toggl.delete_client(c_id)
      end
    end

    projects = toggl.my_projects(user)
    unless projects.nil?
      project_ids ||= projects.map { |p| p['id'] }
      project_ids.each do |p_id|
        toggl.delete_project(p_id)
      end
    end

    tags = toggl.my_tags(user)
      unless tags.nil?
      tag_ids ||= tags.map { |t| t['id'] }
      tag_ids.each do |t_id|
        toggl.delete_tag(t_id)
      end
    end

    time_entrys = toggl.my_time_entries(user)
    unless time_entrys.nil?
      time_entry_ids ||= time_entrys.map { |t| t['id'] }
      time_entry_ids.each do |t_id|
        toggl.delete_time_entry(t_id)
      end
    end

    workspaces = toggl.my_workspaces(user)
    unless workspaces.nil?
      workspace_ids ||= workspaces.map { |w| w['id'] }
      workspace_ids.delete(default_workspace_id)
      workspace_ids.each do |w_id|
        @logger.debug(w_id)
        toggl.leave_workspace(w_id)
      end
    end
  end
end