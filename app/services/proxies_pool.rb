class ProxiesPool
  def initialize
    @pool = REDIS.get("provider.proxy.pool")
  end

  def sample
    JSON.parse(@pool).sample
  rescue
    nil
  end
end
