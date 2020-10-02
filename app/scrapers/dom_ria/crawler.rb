# frozen_string_literal: true

module DomRia
  class Crawler
    def call
      first_response = Faraday.new(DomRia::START_URL, headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0' }).get
      urls = paginate(first_response)
      ids = JSON.parse(first_response.body)['items'].map { |i| i['_id'] }
      persist(ids)
      urls.each do |url|
        page = Faraday.new(url, headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0' }).get
        new_ids = JSON.parse(page.body)['items'].map { |i| i['_id'] }
        persist(new_ids)
      end
    end

    private

    def persist(ids)
      urls = ids.map { |id| "https://dom.ria.com/ru/#{id}.html" }
      existing_urls = Url.where(address: urls, source: DomRia::PROVIDER)
      existing_urls_addresses = existing_urls.select(:address).map(&:address)
      urls_to_persist = urls - existing_urls_addresses
      Url.import(%i[address status source created_at updated_at], urls_to_persist.map { |url| [url, 'pending', DomRia::PROVIDER, Time.now, Time.now] })
      existing_urls.update(status: 'pending')
    end

    def paginate(response)
      json = JSON.parse(response.body)
      count = json['count'].to_f
      number_of_pages = (count / DomRia::CRAWLER_PER_PAGE).ceil
      (1..number_of_pages).map do |page_number|
        DomRia::START_URL.gsub(/\?page=(\d+)/, "?page=#{page_number}")
      end
    end
  end
end
