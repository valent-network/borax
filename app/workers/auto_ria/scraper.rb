module AutoRia
  class Scraper
    include Sidekiq::Worker
    sidekiq_options queue: 'provider-auto-ria-scraper', retry: false, backtrace: false

    def perform
      AutoRia.scrape!(limit: 100)
    end
  end
end
