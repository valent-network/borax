module AutoRia
  class Actualizer
    include Sidekiq::Worker
    sidekiq_options queue: 'provider-auto-ria-actualizer', retry: false, backtrace: false

    def perform
      AutoRia.actualize!
    end
  end
end
