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
  TOGGL_API_URL = 'https://api.track.toggl.com/api/'

  class API
    include TogglV8::Connection

    TOGGL_API_V8_URL = TOGGL_API_URL + 'v8/'

    attr_reader :conn

    def initialize(username=nil, password=API_TOKEN, opts={})
      debug(false)
      if username.nil? && password == API_TOKEN
        toggl_api_file = File.join(Dir.home, TOGGL_FILE)
        # logger.debug("toggl_api_file = #{toggl_api_file}")
        if File.exist?(toggl_api_file) then
          username = IO.read(toggl_api_file).strip
        else
          raise "Expecting one of:\n" +
            " 1) api_token in file #{toggl_api_file}, or\n" +
            " 2) parameter: (api_token), or\n" +
            " 3) parameters: (username, password).\n" +
            "\n\tSee https://github.com/kanet77/togglv8#togglv8api" +
            "\n\tand https://github.com/toggl/toggl_api_docs/blob/master/chapters/authentication.md"
        end
      end

      @conn = TogglV8::Connection.open(username, password,
                TOGGL_API_V8_URL, opts)
    end
  end
end
