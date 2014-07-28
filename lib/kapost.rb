require 'rest_client'
require 'json'

require 'logger'

require 'kapost/version'
require 'kapost/configuration'
require 'kapost/result'
require 'kapost/content'
require 'kapost/content_type'
require 'kapost/custom_fields'
require 'kapost/persona'
require 'kapost/buying_stage'
require 'kapost/client'

module Kapost
  extend Configuration

  class << self
    def logger
      return @logger if defined?(@logger)
      @logger = rails_logger || default_logger
    end

    def logger=(logger)
      @logger = logger
    end

    def rails_logger
      defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
    end

    def default_logger
      return @default_logger if defined?(@default_logger)

      @default_logger = Logger.new(STDOUT)
      @default_logger.level = Logger::INFO
      @default_logger
    end
  end
end
