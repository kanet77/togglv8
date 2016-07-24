require_relative 'clients'
require_relative 'dashboard'
require_relative 'project_users'
require_relative 'projects'
require_relative 'tags'
require_relative 'tasks'
require_relative 'time_entries'
require_relative 'users'
require_relative 'version'
require_relative 'workspaces'

module TogglV8
  TOGGL_API_URL = 'https://www.toggl.com/api/'

  class API
    include TogglV8::Connection

    TOGGL_API_V8_URL = TOGGL_API_URL + 'v8/'

    attr_reader :conn

    def initialize(username=nil, password=API_TOKEN, opts={})
      debug(false)
      @conn = TogglV8::Connection.open(username, password,
                TOGGL_API_V8_URL, opts)
    end
  end
end












