module AutoRia
  class Scraper
    include Sidekiq::Worker
    sidekiq_options queue: 'provider-auto-ria-scraper', retry: false, backtrace: false

    def perform(offset = 0, limit = AutoRia::LIMIT, forced = false)
      AutoRia.scrape!(offset: offset, limit: limit, forced: forced)
    end
  end
end
