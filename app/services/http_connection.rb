# frozen_string_literal: true

class HttpConnection
  REQUEST_OPTIONS = {}.freeze
  attr_reader :connection, :last_response

  def initialize(proxies_pool = ProxiesPool.new)
    random_proxy = proxies_pool.sample

    @connection = Faraday.new do |f|
      f.use FaradayMiddleware::FollowRedirects, limit: 5
      f.adapter Faraday.default_adapter
      f.proxy = random_proxy if random_proxy
    end
  end

  def get(url)
    @last_response = connection.get(url, REQUEST_OPTIONS, request_headers)

    {
      status: last_response.status,
      body: last_response.body,
      json: begin
        JSON.parse(last_response.body)
      rescue StandardError
        nil
      end
    }
  end

  private

  def request_headers
    ua = [
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML like Gecko) Chrome/58.0.3029.110 Safari/537.36",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:53.0) Gecko/20100101 Firefox/53.0",
      "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0; Trident/5.0)",
      "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0; MDDCJS)",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML like Gecko) Chrome/51.0.2704.79 Safari/537.36 Edge/14.14393",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)",
    ]

    {
      'User-Agent' => ua.sample,
      'Accept-Language' => 'en,ru-RU;q=0.8,ru;q=0.5,en-US;q=0.3',
      'Cookie' => 'lang_id=2; lang_code=ru; lang_code=ru'
    }
  end
end
