# frozen_string_literal: true

module AutoRia
  class UrlToHtml
    def call(url)
      headers = {
        'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
        'Accept-Language' => 'en,ru-RU;q=0.8,ru;q=0.5,en-US;q=0.3',
        'Cookie' => 'lang_id=2; lang_code=ru; lang_code=ru'
      }

      conn = Faraday.new do |f|
        f.use FaradayMiddleware::FollowRedirects, limit: 5
        f.adapter Faraday.default_adapter
      end

      response = conn.get(url, {}, headers)
      response.body
    rescue TypeError => e
      Corona.logger.error(e)
      raise(BrokenUrlError, 'type')
    end
  end
end
