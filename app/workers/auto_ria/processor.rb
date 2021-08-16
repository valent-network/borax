# frozen_string_literal: true

module AutoRia
  class Processor
    include Sidekiq::Worker

    sidekiq_options queue: 'provider-auto-ria-processor', retry: true, backtrace: false

    def perform(url_id)
      urls = Url.where(id: url_id, status: 'in_progress').all

      if urls.size.positive?
        UrlsProcessor.new.call(urls)
      else
        puts("[AutoRia::Processor][#{url_id}][Not Found]")
      end
    end
  end
end
