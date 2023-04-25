redis_options = REDIS_CONFIGURATION.dup

redis_options.delete(:password) if redis_options[:password].blank?

Redis.exists_returns_integer = false

Sidekiq.configure_server do |config|
  config.redis = redis_options
  config.logger.level = Corona.logger.level

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
  config.logger.level = Corona.logger.level

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
