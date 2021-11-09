REDIS = Redis.new(
  host: ENV.fetch('REDIS_SERVICE_HOST', 'localhost'),
  password: ENV.fetch('REDIS_SERVICE_PASSWORD', nil),
  port: ENV.fetch('REDIS_SERVICE_PORT', '6379')
)
