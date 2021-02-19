require 'clockwork'

require './config/application'

module Clockwork
  every(1.hour, 'Crawl auto.ria.com') { AutoRia::CrawlerWorker.perform_async }
  every(10.second, 'Scrape auto.ria.com') { AutoRia::Scraper.perform_async }
  every(6.seconds, 'Actualize auto.ria.com') { AutoRia::Actualizer.perform_async }
end
