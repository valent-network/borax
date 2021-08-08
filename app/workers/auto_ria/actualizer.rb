module AutoRia
  class Actualizer
    include Sidekiq::Worker

    sidekiq_options queue: 'provider-auto-ria-actualizer', retry: false, backtrace: false

    def perform(addresses)
      addresses = JSON.parse(addresses)
      Url.where(address: addresses).update(status: 'in_progress')
      Url.where(address: addresses).each { |url| AutoRia::Processor.perform_async(url.id) }
    end
  end
end
