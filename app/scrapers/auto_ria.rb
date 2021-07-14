# frozen_string_literal: true

module AutoRia
  CRAWLER_PER_PAGE = 100
  LIMIT = 1000
  PROVIDER = 'auto.ria.com'
  # top=3 means for 3 days; 11 - day; 5 - month; 0 - all
  START_URL = "https://auto.ria.com/blocks_search_ajax/search/?category_id=1&bodystyle[0]=3&bodystyle[1]=5&bodystyle[3]=4&bodystyle[4]=2&bodystyle[5]=6&bodystyle[7]=7&bodystyle[8]=9&bodystyle[9]=307&bodystyle[12]=315&price_ot=&price_do=&currency=1&abroad=2&custom=-1&under_credit=2&confiscated_car=2&damage=1&auto_repairs=2&sellerType=0&matched_country=0&fuelRateFrom=&fuelRateTo=&fuelRatesType=city&engineVolumeFrom=&engineVolumeTo=&powerFrom=&powerTo=&power_name=1&raceFrom=&raceTo=&doorsFrom=&doorsTo=&seatsFrom=&seatsTo=&order_by=dates.created.desc&top=3&saledParam=2&countpage=#{CRAWLER_PER_PAGE}&class=&purpose=&q=&page=0"
  REQUEST_DELAY_SECONDS = 0.1

  def self.crawl!
    Crawler.new.call
  end

  def self.scrape!(offset: 0, limit: LIMIT, forced: false)
    urls_to_process = Url.offset(offset).limit(limit).where(status: 'pending', source: PROVIDER)
    urls_to_process = urls_to_process.where { updated_at < Time.now.beginning_of_day } unless forced
    urls_ids = urls_to_process.select(:id).map(&:id)

    Url.where(id: urls_ids, status: 'pending').update(status: 'in_progress')
    UrlsProcessor.new.call(Url.where(id: urls_ids, status: 'in_progress').all)
  end

  def self.t(url)
    html = UrlToHtml.new.call(url)
    HtmlToAd.new.call(html)
  end

  def self.actualize!
    urls = JSON.parse(RecarioApi.new.index.body)
    urls.map! do |url|
      Url.find_or_create(address: url) do |u|
        u.status = 'pending'
        u.source = PROVIDER
      end
    end

    UrlsProcessor.new.call(urls)
  end
end
