redis_params = {
  host: ENV.fetch('REDIS_SERVICE_HOST', 'localhost'),
  port: ENV.fetch('REDIS_SERVICE_PORT', '6379')
}

redis_params[:password] = ENV.fetch('REDIS_SERVICE_PASSWORD') if ENV['REDIS_SERVICE_PASSWORD']

REDIS = Redis.new(redis_params)
