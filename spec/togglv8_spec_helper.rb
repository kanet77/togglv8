require_relative '../lib/togglv8'
require 'logger'

class TogglV8SpecHelper
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::WARN

  def self.setUp(toggl)
    user = toggl.me(all=true)
    @default_workspace_id = user['default_wid']

    delete_all_projects(toggl)
    delete_all_clients(toggl)
    delete_all_tags(toggl)
    delete_all_time_entries(toggl)
    delete_all_workspaces(toggl)
  end

  def self.delete_all_clients(toggl)
    clients = toggl.my_clients
    unless clients.nil?
      client_ids ||= clients.map { |c| c['id'] }
      @logger.debug("Deleting #{client_ids.length} clients")
      client_ids.each do |c_id|
        toggl.delete_client(c_id)
      end
    end
  end

  def self.delete_all_projects(toggl)
    projects = toggl.projects(@default_workspace_id)
    unless projects.nil?
      project_ids ||= projects.map { |p| p['id'] }
      @logger.debug("Deleting #{project_ids.length} projects")
      return unless project_ids.length > 0
      toggl.delete_projects(project_ids)
    end
  end

  def self.delete_all_tags(toggl)
    tags = toggl.my_tags
    unless tags.nil?
      tag_ids ||= tags.map { |t| t['id'] }
      @logger.debug("Deleting #{tag_ids.length} tags")
      tag_ids.each do |t_id|
        toggl.delete_tag(t_id)
      end
    end
  end

  def self.delete_all_time_entries(toggl)
    time_entries = toggl.get_time_entries(
      { :start_date => DateTime.now - 30, :end_date => DateTime.now + 30 } )
    unless time_entries.nil?
      time_entry_ids ||= time_entries.map { |t| t['id'] }
      @logger.debug("Deleting #{time_entry_ids.length} time_entries")
      time_entry_ids.each do |t_id|
        toggl.delete_time_entry(t_id)
      end
    end
  end

  def self.delete_all_workspaces(toggl)
    user = toggl.me(all=true)
    workspaces = toggl.my_workspaces(user)
    unless workspaces.nil?
      workspace_ids ||= workspaces.map { |w| w['id'] }
      workspace_ids.delete(user['default_wid'])
      @logger.debug("Leaving #{workspace_ids.length} workspaces")
      workspace_ids.each do |w_id|
        toggl.leave_workspace(w_id)
      end
    end
  end
end