# frozen_string_literal: true

module AutoRia
  CRAWLER_PER_PAGE = 100
  LIMIT = 1000
  PROVIDER = 'auto.ria.com'
  # top=3 means for 3 days; 11 - day; 5 - month; 0 - all
  # category_id=1 -- passenger, 2 -- moto, 3 -- trucks
  # OLD_START_URL = "https://auto.ria.com/blocks_search_ajax/search/?bodystyle[0]=3&bodystyle[1]=5&bodystyle[3]=4&bodystyle[4]=2&bodystyle[5]=6&bodystyle[7]=7&bodystyle[8]=9&bodystyle[9]=307&bodystyle[12]=315&price_ot=&price_do=&currency=1&abroad=2&custom=-1&under_credit=2&confiscated_car=2&damage=1&auto_repairs=2&sellerType=0&matched_country=0&fuelRateFrom=&fuelRateTo=&fuelRatesType=city&engineVolumeFrom=&engineVolumeTo=&powerFrom=&powerTo=&power_name=1&raceFrom=&raceTo=&doorsFrom=&doorsTo=&seatsFrom=&seatsTo=&order_by=dates.created.desc&top=3&saledParam=2&countpage=#{CRAWLER_PER_PAGE}&class=&purpose=&q=&page=0"

  # top=10 means for 2 days (?)
  # order_by=7 means by date
  START_URL = "https://auto.ria.com/api/search/auto?indexName=auto&order_by=7&top=10&abroad=2&custom=1&page=1&countpage=#{CRAWLER_PER_PAGE}&with_feedback_form=1&withOrderAutoInformer=1&with_last_id=1".freeze
  AD_SCRAPE_FREQUENCE = 12.hours

  def self.t(url)
    html = HttpConnection.new.get(url)[:body]
    Parser.new.call(html)
  rescue TypeError => e
    Corona.logger.error(e)
    raise(BrokenUrlError, 'type')
  end
end
