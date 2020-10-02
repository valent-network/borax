# frozen_string_literal: true

module DomRia
  CRAWLER_PER_PAGE = 10_000
  LIMIT = 1000
  PROVIDER = 'dom.ria.com'
  START_URL = "https://dom.ria.com/searchEngine/?page=0&limit=#{CRAWLER_PER_PAGE}"
  PROXIES = %w[
    HTTP://180.252.181.2:80
    HTTPS://140.227.227.95:3128
    HTTP://91.205.174.26:80
    HTTP://118.69.50.154:80
    HTTPS://88.199.21.76:80
    HTTPS://165.22.106.66:44344
    HTTP://80.241.222.137:80
    HTTPS://117.1.16.131:8080
    HTTP://125.16.18.182:80
    HTTPS://140.227.174.216:1000
    HTTPS://51.158.172.165:8811
    HTTPS://128.199.203.84:44344
    HTTP://80.241.222.138:80
    HTTP://118.69.50.154:443
    HTTPS://165.22.98.224:44344
    HTTPS://140.227.237.154:1000
    HTTP://183.88.92.205:3128
    HTTP://200.89.178.210:80
    HTTPS://144.217.101.242:3129
    HTTPS://163.172.189.32:8811
    HTTPS://140.227.173.230:1000
    HTTP://167.99.0.84:80
    HTTPS://128.199.203.193:44344
    HTTPS://140.227.175.225:1000
    HTTPS://128.199.193.37:44344
    HTTP://113.53.230.167:80
    HTTP://180.252.181.3:80
    HTTPS://128.199.244.47:44344
    HTTPS://118.163.83.21:3128
    HTTPS://140.227.210.123:3128
    HTTPS://178.128.93.68:44344
    HTTP://12.139.101.100:80
    HTTPS://165.22.98.206:44344
    HTTPS://167.114.68.9:3128
    HTTP://128.199.238.162:44344
    HTTP://31.14.133.130:8080
    HTTPS://128.199.200.236:44344
    HTTPS://51.158.107.202:8811
    HTTP://52.179.231.206:80
    HTTPS://140.227.229.208:3128
    HTTPS://128.199.251.160:44344
    HTTPS://128.199.121.141:3128
  ].freeze

  def self.crawl!
    Crawler.new.call
  end

  def self.scrape!(offset = 0, limit = LIMIT, forced = false)
    urls_to_process = Url.offset(offset).limit(limit).where(status: 'pending', source: PROVIDER)
    urls_to_process = urls_to_process.where(updated_at: Time.now.beginning_of_day) unless forced
    urls_ids = urls_to_process.select(:id).map(&:id)
    Url.where(id: urls_ids).update(status: 'in_progress')
    UrlsProcessor.new.call(Url.where(id: urls_ids).all)
  end

  def self.t(url)
    conn = Faraday.new do |f|
      f.use FaradayMiddleware::FollowRedirects, limit: 5
      f.adapter Faraday.default_adapter
      f.proxy = DomRia::PROXIES.sample
    end
    response = conn.get(url)
    html = response.body
    doc = Nokogiri::HTML(html)
    jscode = doc.search('script').find { |scr| scr.attributes.zero? }.text
    res = JSON.parse(jscode.gsub(/window\.__INITIAL_STATE__=(.+)(};\(.*$)/, '\1}'))

    # realty_hash = res['dataForFinalPage']['hash']
    # details = JSON.parse(Faraday.new("https://dom.ria.com/v1/api/realty/getOwnerAndAgencyData/#{realty_hash}").get.body)
    # res[:phone] = details['owner']['phones'].first['phone_num']
    # res[:details] = details
    realty = res['dataForFinalPage']['realty']
    res[:phone] = res['dataForFinalPage']['firstPhone']['phone']
    res[:images_json_array_tmp] = realty['photos'].map { |photo| "https://cdn.riastatic.com/photos/#{photo['file']}".gsub(/.jpg$/, 'fl.jpg') }.to_json
    res[:total_square_meters] = realty['total_square_meters']
    res[:realty_type_name] = realty['realty_type_name']
    res[:floors_count] = realty['floors_count']
    res[:floor] = realty['floor']
    res[:is_sold] = realty['isSold']
    res[:is_active] = realty['isActive']
    res[:is_archive] = realty['isArchive']
    res[:is_draft] = realty['isDraft']
    res[:is_owner] = realty['isOwner']
    res[:state] = realty['state_name']
    res[:city] = realty['city_name']
    res[:currency_type] = realty['currency_type']
    res[:rooms_count] = realty['rooms_count']
    res[:status] = realty['status']
    res[:delted_by_moderator] = realty['deletedByModerator']
    res[:wall_type] = realty['wall_type']
    res[:street_name] = realty['street_name']
    res[:is_commercial] = realty['is_commercial']
    res[:description] = realty['description']
    res[:price_total] = realty['price_total']
    res[:advert_type_name] = realty['advert_type_name']
    res[:agency_id] = realty['agency_id']
    res[:district_name] = realty['district_name']
    res[:publishing_date] = realty['publishing_date']
    puts res
    res
  rescue StandardError => e
    Corona.logger.error(e)
  end
end
