# frozen_string_literal: true

module DomRia
  class HtmlToAd
    def call(html)
      result = {}
      doc = Nokogiri::HTML(html)

      result[:price] = doc.search('.price').text.gsub(/\s/, '').to_i
      result[:images_json_array_tmp] = doc.search('.finalGallery img').map { |img| img['src'].gsub(/m\.jpg$/, 'fl.jpg') }
      result[:description] = doc.search('#descriptionBlock').text
      # result[:phone] = @phone

      result
    rescue StandardError => e
      raise(BrokenUrlError, "#{e.message}\n#{e.backtrace.reject { |s| s.scan(/\.rbenv/).any? }}")
    end
  end
end
