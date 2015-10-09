require 'faraday'
require 'oj'

require 'logger'
require 'awesome_print' # for debug output

require_relative 'toggl_base_api'

require_relative 'togglv8/clients'
require_relative 'togglv8/dashboard'
require_relative 'togglv8/project_users'
require_relative 'togglv8/projects'
require_relative 'togglv8/tags'
require_relative 'togglv8/tasks'
require_relative 'togglv8/time_entries'
require_relative 'togglv8/users'
require_relative 'togglv8/version'
require_relative 'togglv8/workspaces'

# mode: :compat will convert symbols to strings
Oj.default_options = { mode: :compat }

module TogglV8
  TOGGL_API_BASE_URL = 'https://www.toggl.com/api/'

  class API < TogglBaseApi

    def self.toggl_api_url
      TOGGL_API_BASE_URL + 'v8/'
    end

  end

end
