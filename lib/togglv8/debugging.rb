require_relative 'logging'

module TogglV8
  module Debugging
    include TogglV8::Logging
    # logger.level = Logger::WARN

    def debug(debug=true)
      if debug
        self.logger.level = Logger::DEBUG
      else
        self.logger.level = Logger::WARN
      end
    end
  end
end
