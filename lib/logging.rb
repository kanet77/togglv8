# :nocov:
require 'logger'

# From http://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
module Logging
  class << self
    def logger
      @logger ||= Logger.new($stdout)
    end

    def logger=(logger)
      @logger = logger
    end
  end

  # Addition
  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end

  def logger
    Logging.logger
  end

  def debug(debug=true)
    if debug
      logger.level = Logger::DEBUG
    else
      logger.level = Logger::WARN
    end
  end
end
# :nocov:
