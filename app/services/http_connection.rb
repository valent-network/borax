class HttpConnection
  REQUEST_HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
    'Accept-Language' => 'en,ru-RU;q=0.8,ru;q=0.5,en-US;q=0.3',
    'Cookie' => 'lang_id=2; lang_code=ru; lang_code=ru'
  }.freeze
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
    @last_response = connection.get(url, REQUEST_OPTIONS, REQUEST_HEADERS)

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
end
