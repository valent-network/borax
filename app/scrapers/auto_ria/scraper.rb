module AutoRia
  class Scraper
    def call(url)
      data = {details: {address: url}, deleted: true}
      response = HttpConnection.new.get(url)
      raise(BrokenUrlError, "too_many_rps") if response[:status] == 429

      data = AutoRia::Parser.new.call(response[:body]) unless response[:status] == 404
      data[:details][:address] = url

      Sentry.capture_message("[AutoRia::Scraper][FinishedSuccessfully] address=#{url} deleted=#{data[:deleted]}", level: :info)

      data
    end
  end
end
