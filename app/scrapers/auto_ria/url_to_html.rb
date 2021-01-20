# frozen_string_literal: true

module AutoRia
  class UrlToHtml
    def call(url)
      connection.get(url, REQUEST_OPTIONS, REQUEST_HEADERS).body
    rescue TypeError => e
      Corona.logger.error(e)
      raise(BrokenUrlError, 'type')
    end

    private

    def connection
      @connection ||= Faraday.new do |f|
        f.use FaradayMiddleware::FollowRedirects, limit: 5
        f.adapter Faraday.default_adapter
      end
    end
  end
end
