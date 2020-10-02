# frozen_string_literal: true

module AutoRia
  class UrlsProcessor
    def call(urls)
      headers = {
        'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
        'Accept-Language' => 'en,ru-RU;q=0.8,ru;q=0.5,en-US;q=0.3',
        'Cookie' => 'lang_id=2; lang_code=ru; lang_code=ru'
      }
      conn = Faraday.new do |f|
        f.use FaradayMiddleware::FollowRedirects, limit: 5
        f.adapter Faraday.default_adapter
      end
      urls.each do |url_record|
        data = { details: { address: url_record.address }, deleted: true }
        response = conn.get(url_record.address, {}, headers)
        data = HtmlToAd.new.call(response.body) unless response.status == 404
        data[:details][:address] = url_record.address
        if data[:deleted] == true
          if RecarioApi.new.delete(data)
            url_record.update(status: 'deleted')
          else
            url_record.update(status: 'failed')
          end
        else
          if RecarioApi.new.update(data)
            url_record.update(status: 'completed')
          else
            url_record.update(status: 'failed')
          end
        end
      rescue FaradayMiddleware::RedirectLimitReached
        if RecarioApi.new.delete(data)
          url_record.update(status: 'deleted')
        else
          url_record.update(status: 'failed')
        end
      rescue OpenURI::HTTPError => e
        Corona.logger.error(e)
        url_record.update(status: "broken_url_#{e.message}}")
      rescue StandardError => e
        Corona.logger.error(e)
        url_record.update(status: 'broken_data_request')
      rescue BrokenUrlError => e
        Corona.logger.error(e)
        url_record.update(status: "broken_url_#{e.message}}")
      end
    end
  end
end
