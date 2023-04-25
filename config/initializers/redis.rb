# frozen_string_literal: true

REDIS_CONFIGURATION = if ENV['REDIS_SENTINEL_ENABLED'].present?
  sentinels = ENV['REDIS_SENTINELS'].to_s.split(',').map(&:strip).map { |s| s.split(':') }.map { |s| { host: s.first, port: s.last, password: ENV['REDIS_PASSWORD'] } }
  {
    name: ENV['REDIS_MASTER_SET'],
    sentinels: sentinels,
    role: :master,
    host: ENV['REDIS_MASTER_SET'],
    password: ENV['REDIS_PASSWORD'],
  }
else
  {
    host: ENV.fetch('REDIS_SERVICE_HOST', 'localhost'),
    password: ENV.fetch('REDIS_SERVICE_PASSWORD', nil),
    port: ENV.fetch('REDIS_SERVICE_PORT', '6379'),
  }
end

REDIS = Redis.new(REDIS_CONFIGURATION)
