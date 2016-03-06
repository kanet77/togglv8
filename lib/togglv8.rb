require_relative 'togglv8/version'

require_relative 'togglv8/connection'

require_relative 'togglv8/togglv8'
require_relative 'togglv8/reportsv2'

# :mode => :compat will convert symbols to strings
Oj.default_options = { :mode => :compat }
