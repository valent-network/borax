# frozen_string_literal: true

module DomRia
  class UrlsProcessor
    def call(urls)
      urls.each do |url_record|
        # html = UrlToHtml.new.call(url_record.address)
        data = HtmlToAd.new.call(url_record.address).merge(url_id: url_record.id)
        if RecarioApi.new.update(data)
        end
      rescue OpenURI::HTTPError => e
        url_record.update!(status: "broken_url_#{e.message}}")
        url_record.ad.update(deleted: true) if url_record.ad.present?
      rescue StandardError
        url_record.update!(status: 'broken_data_request')
        url_record.ad.update(deleted: true) if url_record.ad.present?
      rescue AutoRia::BrokenUrlError => e
        url_record.update!(status: "broken_url_#{e.message}}")
        url_record.ad.update(deleted: true) if url_record.ad.present?
      end
    end
  end
end
