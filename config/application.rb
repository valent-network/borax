# frozen_string_literal: true

require "./lib/corona"

Bundler.require(:default, Corona.env)

Dotenv.load("#{Corona.root}/.env", "#{Corona.root}/.env.#{Corona.env}")

Corona.mount_auto_loader!

Corona.logger.level = begin
  ENV["CORONA_LOG_LEVEL"].present? ? "Logger::#{ENV["CORONA_LOG_LEVEL"].upcase}".constantize : Logger::WARN
rescue NameError
  Logger::WARN
end

require_relative "initializers/redis"
require_relative "initializers/sidekiq"

module Urls
  class Application # rubocop:disable Lint/EmptyClass
  end
end
