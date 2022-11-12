REDIS = Redis.new(
  host: ENV.fetch('REDIS_SERVICE_HOST', 'localhost'),
  port: ENV.fetch('REDIS_SERVICE_PORT', '6379')
)
