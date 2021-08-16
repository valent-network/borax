class UrlsPersister
  def call(ids)
    urls = ids.map { |id| "https://auto.ria.com/auto_title_id_#{id}.html" }
    existing_urls = Url.where(address: urls)
    existing_urls_addresses = existing_urls.select(:address).map(&:address)
    urls_to_persist = urls - existing_urls_addresses

    Url.import(%i[address status source created_at updated_at], urls_to_persist.map { |url| [url, 'in_progress', AutoRia::PROVIDER, Time.now, Time.now] })
    existing_urls.update(status: 'in_progress')

    Url.where(address: urls).each { |url| AutoRia::Processor.perform_in(12.hours, url.id) }
  end
end
