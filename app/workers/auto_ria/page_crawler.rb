# frozen_string_literal: true

module AutoRia
  class PageCrawler
    include Sidekiq::Worker

    sidekiq_options queue: 'provider', retry: true, backtrace: false

    def perform(url, index)
      page = HttpConnection.new.get(url)
      ids = JSON.parse(page[:body])['result']['search_result']['ids']

      UrlsPersister.new.call(ids)

      Sidekiq.logger.info("[PageCrawler][#{index.to_i + 1}][Finished]")
    end
  end
end
