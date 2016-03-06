require 'logger'
require 'awesome_print' # for debug output

module TogglV8
  module Logging
    def logger
      Logging.logger
    end

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end