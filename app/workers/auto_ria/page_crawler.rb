# frozen_string_literal: true

module AutoRia
  class PageCrawler
    include Sidekiq::Worker

    sidekiq_options queue: "provider", retry: true, backtrace: false

    def perform(url, index)
      page = HttpConnection.new.get(url)
      ids = JSON.parse(page[:body])["result"]["search_result"]["ids"]

      UrlsPersister.new.call(ids)

      Sidekiq.logger.warn("[PageCrawler][Finished] index=#{index.to_i + 1} ids=#{ids.to_json}")
    end
  end
end
