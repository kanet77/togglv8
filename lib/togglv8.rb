require_relative 'togglv8/version'

require_relative 'togglv8/connection'

require_relative 'togglv8/togglv8'
require_relative 'reportsv2'

# :mode => :compat will convert symbols to strings
Oj.default_options = { :mode => :compat }

module TogglV8
  NAME = "TogglV8 v#{TogglV8::VERSION}"
end