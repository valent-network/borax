# frozen_string_literal: true

module AutoRia
  class Parser
    attr_reader :doc, :result, :details

    def initialize
      @result = {}
    end

    def call(html)
      @doc = Nokogiri::HTML(html)
      doc.css('.orange').remove # Remove not defined by seller blocks
      result[:deleted] = doc.search('#autoDeletedTopBlock').size >= 1
      return result.merge(details: {}) if result[:deleted]

      @details =
        begin
          JSON.parse(doc.search("//script[@type='application/ld+json']").first)
        rescue StandardError
          {}
        end
      result[:new_car] = (doc.xpath("//a[@href='#first-registration']").size >= 1 || doc.search('.base-information').try(:text).to_s.downcase =~ /без пробега/) || false
      result[:year] = details['productionDate'] || doc.search('h1.head').first.try(:[], 'title').to_s.scan(/\s((?:19|20)\d\d\Z)/).flatten.first
      set_new_car_related_fields!

      return { deleted: true, details: {} } if result[:maker].blank? || result[:model].blank? || result[:year] <= 0

      fuel = doc.search('.vin-checked .technical-info.ticket-checked').xpath(".//dd[./span[text()='Двигатель']]/span[2]").xpath('text()').text.gsub(/\d л/, '').gsub(/\(.+\)/, '').gsub(/[\d.]/, '').strip.presence ||
             doc.search('#details').xpath(".//dd[./span[text()='Двигатель']]/span[2]").xpath('text()').text.gsub(/\d л/, '').gsub(/[\d.]/, '').gsub(/\(.+\)/, '').strip.presence

      engine_capacity = doc.search('.vin-checked .technical-info.ticket-checked').xpath(".//dd[./span[text()='Двигатель']]/span[2]").xpath('text()').try(:text).to_s.gsub(/л\.с\./, '').gsub(/(\d+(\.\d+)?) л(.+)?/, '\1').presence ||
                        doc.search('#details').xpath(".//dd[./span[text()='Двигатель']]/span[2]").xpath('text()').try(:text).to_s.gsub(/л\.с\./, '').gsub(/(\d+(\.\d+)?) л(.+)?/, '\1').presence

      hp = doc.search('#details').xpath(".//dd[./span[text()='Двигатель']]/span[2]").xpath('text()').text.scan(/(?:(?:(\d+(?:\.\d+)?) л\.с\.(?:.+)?))/).flatten.first

      result[:gear] = details['vehicleTransmission'] || doc.xpath("//dd[./span[text()='Коробка передач']]/span[2]").try(:text).to_s.strip
      result[:fuel] = details['fuelType'] || fuel
      result[:engine_capacity] = engine_capacity ? (engine_capacity.to_f * 1000).to_i : nil
      result[:horse_powers] = hp ? hp.to_i : nil
      result[:carcass] = details['bodyType'] || doc.search('#details dd').first.text.split('•').first&.strip
      result[:carcass] = result[:carcass].to_s.gsub(/\d/, '').gsub(/мест/, '').gsub(/дверей/, '').gsub(/Пробег/, '').gsub(/тыс. км/, '').strip.presence
      result[:wheels] = doc.xpath("//dd[./span[text()='Привод']]/span[2]").try(:text).to_s.strip
      result[:color] = doc.search('#details').xpath(".//dd[./span[text()='Цвет']]/span[2]").try(:first).try(:text).to_s.strip.presence ||
                       doc.xpath("//dd[./span[text()='Цвет']]/span[2]").try(:first).try(:text).to_s.strip
      result[:phone] = doc.search('a[data-call]').first.try(:[], :href).to_s.gsub(/^tel:/, '').presence ||
                       doc.search('a[data-call]').first.try(:[], 'data-call').to_s.presence ||
                       doc.search('span.phone').first&.attribute('data-phone-number').try(:text).presence ||
                       JSON.parse(CGI.unescape(doc.search('.phone.bold').first.try(:[], 'data-phone-unmask'))).try(:[], 'phoneNumber').presence
      result[:region] = [doc.search('#breadcrumbs .item span').try(:[], 1).try(:text), doc.search('#breadcrumbs .item span').try(:[], 2).try(:text)]
      result[:images_json_array_tmp] = doc.search('.gallery-order img').map { |i| i['src'] }.map { |src| src.gsub(/s\.jpg$/, 'f.jpg') }.to_json
      result[:customs_clear] = doc.search('.not-cleared').empty?
      result[:deleted] = doc.search('#autoDeletedTopBlock').size >= 1
      result[:description] = doc.search('.additional-data').try(:text).to_s.gsub(/Описание/, '').gsub(/Читать еще Скрыть/, '').strip
      result[:state_num] = doc.search('span.state-num').first&.children&.first&.text&.strip
      result[:seller_name] = doc.search('#userInfoBlock .seller_info_name')&.text&.strip
      result[:seller_name] = nil if result[:seller_name] == 'Имя не указано'

      set_price!

      unless result[:phone].include?('xxx').nil?
        begin
          ad_id = doc.search('li.item.grey').find { |node| node.text.include?('ID') }.search('span').text
          phone_details_url = "https://auto.ria.com/users/phones/#{ad_id}?hash=#{doc.search('script[data-hash]').first['data-hash']}&expires=#{doc.search('script[data-hash]').first['data-expires']}"
          phone_details_json = JSON.parse(HttpConnection.new.get(phone_details_url)[:body])
          result[:phone] = phone_details_json['formattedPhoneNumber']
        rescue StandardError => e
          puts e
        end
      end

      {
        price: result.delete(:price),
        deleted: result.delete(:deleted),
        phone: result.delete(:phone),
        ad_type: 'car',
        details: result
      }
    rescue StandardError => e
      raise(BrokenUrlError, "#{e.message}\n#{e.backtrace.reject { |s| s.scan(/\.rbenv/).any? }}")
    end

    private

    def set_new_car_related_fields!
      breadcrumbs = doc.search('#showBreadcrumbs .item span').presence ||
                    doc.search('#breadcrumbs span').presence ||
                    doc.search('.breadcrumbs span').presence

      return {} unless breadcrumbs

      if result[:new_car]
        result[:maker] = breadcrumbs[breadcrumbs.size - 2].try(:text).presence || details['brand'].try(:[], 'name')
        result[:model] = breadcrumbs[breadcrumbs.size - 1].try(:text).presence || details['model']
        result[:race] = 0
      else
        result[:maker] = details['brand'].try(:[], 'name') || breadcrumbs[breadcrumbs.size - 2].try(:text).presence
        result[:model] = details['model'] || breadcrumbs[breadcrumbs.size - 1].try(:text).presence
        result[:race] = details['mileageFromOdometer'].try(:[], 'value') || (doc.xpath("//dd[./span[text()='Пробег']]/span[2]").try(:text).to_s.strip.gsub(/[^\s\w]/, '').strip.to_i * 1000)
      end
    end

    def set_price!
      price = doc.search('div.price_value').try(:text).to_s.strip.scan(/[\d\s]+\$/).uniq.first.presence ||
              doc.search(".price_value--additional span[@data-currency='USD']").first.try(:text).presence ||
              doc.search(".price-at-rate span[@data-currency='USD']").try(:text).presence ||
              doc.search('span.price').first.try(:text).presence ||
              (details['offers'].try(:[], 'priceCurrency').to_s.casecmp('usd').zero? ? details['offers'].try(:[], 'price') : 0)
      result[:price] = price.to_s.gsub(/[\s$]/, '').to_i
    end
  end
end
