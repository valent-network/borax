# frozen_string_literal: true

module AutoRia
  class AdProcessor
    include Sidekiq::Worker

    sidekiq_options queue: 'provider',
                    retry: true,
                    backtrace: false,
                    lock: :until_executed

    def perform(url)
      data = AutoRia::Scraper.new.call(url)

      data[:deleted] == true ? delete(url) : put(data)
    rescue FaradayMiddleware::RedirectLimitReached => e
      delete(url)
      Sidekiq.logger.warn("[UrlsProcessor][FaradayMiddleware::RedirectLimitReached] url=#{url} error_message=#{e.message} error=#{e}")
    rescue OpenURI::HTTPError => e
      Sidekiq.logger.warn("[UrlsProcessor][OpenURI::HTTPError] url=#{url} error_message=#{e.message} error=#{e}")
    rescue BrokenUrlError => e
      Sidekiq.logger.warn("[UrlsProcessor][BrokenUrlError] url=#{url} error_message=#{e.message} error=#{e}")
    rescue StandardError => e
      Sidekiq.logger.warn("[UrlsProcessor][StandardError] url=#{url} error_message=#{e.message} error=#{e}")
    end

    private

    def delete(url)
      callback('DeleteAd', 'ads', url)
    end

    def put(data)
      callback('PutAd', 'ads', Base64.urlsafe_encode64(Zlib.deflate(data.to_json)))
    end

    def callback(klass, queue, params)
      Sidekiq::Client.push(
        'class' => klass,
        'args' => [params],
        'queue' => queue,
        'retry' => true,
        'backtrace' => false
      )
    end
  end
end
