module AutoRia
  class Actualizer
    include Sidekiq::Worker

    sidekiq_options queue: 'provider-auto-ria-actualizer', retry: false, backtrace: false

    def perform(addresses)
      addresses = JSON.parse(addresses)

      existing_urls = Url.where(address: addresses)
      existing_urls_addresses = existing_urls.select(:address).map(&:address)
      addresses_to_persist = addresses - existing_urls_addresses

      Url.import(%i[address status source created_at updated_at], addresses_to_persist.map { |address| [address, 'pending', AutoRia::PROVIDER, Time.now, Time.now] })
      existing_urls.update(status: 'pending')

      Url.where(address: addresses).each { |url| AutoRia::Processor.perform_async(url.id) }
    end
  end
end
