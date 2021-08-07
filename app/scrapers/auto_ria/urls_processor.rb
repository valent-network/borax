# frozen_string_literal: true

module AutoRia
  class UrlsProcessor
    RECEIVERS = {
      delete: { queue: 'provider-ads-delete', class: 'DeleteAd' },
      new: { queue: 'provider-ads-new', class: 'PutAd' }
    }.freeze

    attr_reader :html_to_ad_service

    def initialize
      @html_to_ad_service = HtmlToAd.new
    end

    def call(urls)
      urls.each do |url_record|
        data = url_to_data(url_record.address)

        if data[:deleted] == true
          callback(RECEIVERS[:delete][:class], RECEIVERS[:delete][:queue], url_record.address)
        else
          callback(RECEIVERS[:new][:class], RECEIVERS[:new][:queue], data.to_json)
        end

        sleep(REQUEST_DELAY_SECONDS)
      rescue FaradayMiddleware::RedirectLimitReached
        callback(RECEIVERS[:delete][:class], RECEIVERS[:delete][:queue], url_record.address)
      rescue OpenURI::HTTPError => e
        Corona.logger.error(e)
        url_record.update(status: "broken_url_#{e.message}")
      rescue BrokenUrlError => e
        Corona.logger.error(e)
        url_record.update(status: "broken_url_#{e.message}")
      rescue StandardError => e
        Corona.logger.error(e)
        url_record.update(status: 'broken_data_request')
      end
    end

    private

    def url_to_data(url)
      data = { details: { address: url }, deleted: true }
      response = HttpConnection.new.get(url)
      raise(BrokenUrlError, 'too_many_rps') if response.status == 429

      data = html_to_ad_service.call(response.body) unless response.status == 404
      data[:details][:address] = url

      data
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
