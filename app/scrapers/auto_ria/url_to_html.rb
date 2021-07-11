# frozen_string_literal: true

module AutoRia
  class UrlToHtml
    def call(url)
      HttpConnection.new.get(url).body
    rescue TypeError => e
      Corona.logger.error(e)
      raise(BrokenUrlError, 'type')
    end
  end
end
