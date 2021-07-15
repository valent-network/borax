module AutoRia
  class CrawlerWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'provider-auto-ria-crawler', retry: true, backtrace: false

    def perform
      last_finished_at_or_nil = REDIS.get('provider.crawler.finished_at')
      last_finished_at = DateTime.parse(last_finished_at_or_nil || 1.day.ago.to_s)
      return if last_finished_at > Time.now - 1.hour

      AutoRia.crawl!
      REDIS.set('provider.crawler.finished_at', Time.now)
    end
  end
end
