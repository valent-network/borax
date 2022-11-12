class UrlsPersister
  def call(ids)
    urls = ids.map { |id| "https://auto.ria.com/auto_title_id_#{id}.html" }

    urls.each { |url| AutoRia::AdProcessor.perform_in(AutoRia::AD_SCRAPE_FREQUENCE, url) }
  end
end
