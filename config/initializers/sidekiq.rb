redis_options = {
  host: ENV.fetch('REDIS_SERVICE_HOST', 'localhost'),
  password: ENV.fetch('REDIS_SERVICE_PASSWORD', nil),
  port: ENV.fetch('REDIS_SERVICE_PORT', '6379')
}

redis_options.delete(:password) if redis_options[:password].blank?

Sidekiq.configure_server do |config|
  config.redis = redis_options

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = redis_options

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
