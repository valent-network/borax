# frozen_string_literal: true

module AutoRia
  class Crawler
    def call
      conn = Faraday.new do |f|
        f.use FaradayMiddleware::FollowRedirects, limit: 5
        f.adapter Faraday.default_adapter
      end
      first_response = conn.get(AutoRia::START_URL)
      urls = paginate(first_response)
      ids = JSON.parse(first_response.body)['result']['search_result']['ids']
      persist(ids)
      urls.each_with_index do |url, index|
        page = conn.get(url)
        new_ids = JSON.parse(page.body)['result']['search_result']['ids']
        persist(new_ids)
        puts "Page #{index + 1} finished"
        sleep(0.3)
      end
    end

    private

    def persist(ids)
      urls = ids.map { |id| "https://auto.ria.com/auto_title_#{id}.html" }
      existing_urls = Url.where(address: urls)
      existing_urls_addresses = existing_urls.select(:address).map(&:address)
      urls_to_persist = urls - existing_urls_addresses
      Url.import(%i[address status source created_at updated_at], urls_to_persist.map { |url| [url, 'pending', AutoRia::PROVIDER, Time.now, Time.now] })
      existing_urls.update(status: 'pending')
    end

    def paginate(response)
      json = JSON.parse(response.body)
      count = json['result']['search_result']['count'].to_f
      number_of_pages = (count / AutoRia::CRAWLER_PER_PAGE).ceil
      (1..number_of_pages).map do |page_number|
        AutoRia::START_URL.gsub(/&page=(\d+)/, "&page=#{page_number}")
      end
    end
  end
end
