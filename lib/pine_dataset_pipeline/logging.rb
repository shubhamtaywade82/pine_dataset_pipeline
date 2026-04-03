# frozen_string_literal: true

require "logger"

module PineDatasetPipeline
  class << self
    attr_writer :logger

    def logger
      @logger ||= build_default_logger
    end

    private

    def build_default_logger
      Logger.new($stderr, progname: "pine_docs_sync").tap do |log|
        log.level = log_level_from_env
        log.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.strftime('%Y-%m-%dT%H:%M:%S')} #{progname} #{severity} -- #{msg}\n"
        end
      end
    end

    def log_level_from_env
      case ENV.fetch("PINE_DOCS_SYNC_LOG_LEVEL", "info").downcase
      when "debug" then Logger::DEBUG
      when "warn" then Logger::WARN
      when "error" then Logger::ERROR
      else Logger::INFO
      end
    end
  end
end
