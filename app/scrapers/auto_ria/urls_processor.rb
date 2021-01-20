# frozen_string_literal: true

module AutoRia
  class UrlsProcessor
    attr_reader :html_to_ad_service, :recario_api_service

    def initialize
      @html_to_ad_service = HtmlToAd.new
      @recario_api_service = RecarioApi.new
    end

    def call(urls)
      urls.each do |url_record|
        data = url_to_data(url_record.address)

        if data[:deleted] == true
          status = recario_api_service.delete(data) ? 'deleted' : 'failed'
        else
          status = recario_api_service.update(data) ? 'completed' : 'failed'
        end

        url_record.update(status: status)
      rescue FaradayMiddleware::RedirectLimitReached
        status = recario_api_service.delete(data) ? 'deleted' : 'failed'
        url_record.update(status: status)
      rescue OpenURI::HTTPError => e
        Corona.logger.error(e)
        url_record.update(status: "broken_url_#{e.message}}")
      rescue BrokenUrlError => e
        Corona.logger.error(e)
        url_record.update(status: "broken_url_#{e.message}}")
      rescue StandardError => e
        Corona.logger.error(e)
        url_record.update(status: 'broken_data_request')
      end
    end

    private

    def url_to_data(url)
      data = { details: { address: url }, deleted: true }
      response = connection.get(url, REQUEST_OPTIONS, REQUEST_HEADERS)
      data = html_to_ad_service.call(response.body) unless response.status == 404
      data[:details][:address] = url

      data
    end

    def connection
      @connection ||= Faraday.new do |f|
        f.use FaradayMiddleware::FollowRedirects, limit: 5
        f.adapter Faraday.default_adapter
      end
    end
  end
end
