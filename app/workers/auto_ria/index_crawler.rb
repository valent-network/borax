# frozen_string_literal: true

module AutoRia
  class IndexCrawler
    include Sidekiq::Worker

    sidekiq_options queue: "provider",
      retry: true,
      backtrace: false,
      lock: :until_expired,
      lock_ttl: 1.hour

    def perform
      first_response = HttpConnection.new.get(START_URL)
      urls = paginate(first_response)
      ids = JSON.parse(first_response[:body])["result"]["search_result"]["ids"]
      UrlsPersister.new.call(ids)
      Sentry.capture_message("[IndexCrawler][Finished] urls=#{urls.to_json} ids=#{ids.to_json}", level: :info)
      urls.each_with_index do |url, index|
        AutoRia::PageCrawler.perform_async(url, index)
      end
    end

    private

    def paginate(response)
      json = JSON.parse(response[:body])
      count = json["result"]["search_result"]["count"].to_f
      number_of_pages = (count / CRAWLER_PER_PAGE).ceil
      (1..number_of_pages).map do |page_number|
        START_URL.gsub(/&page=(\d+)/, "&page=#{page_number}")
      end
    end
  end
end
