module DomRia
  class UrlToHtml
    def call(url_address)
      options = Selenium::WebDriver::Firefox::Options.new
      # options.headless!
      driver = Selenium::WebDriver.for :firefox, options: options
      wait = Selenium::WebDriver::Wait.new
      driver.navigate.to url_address
      html = driver.find_element(css: 'html').attribute('innerHTML')

      # GET PHONE
      begin
        driver.find_element(css: '.c-notifier-btn-close.c-notifier-btn').click
      rescue StandardError
        nil
      end

      wait.until { driver.find_element(css: 'li[data-tm*="phone"]').displayed? }
      driver.find_element(css: 'li[data-tm*="phone"]').click
      begin
        wait.until { driver.find_element(css: '.pointer[title="Скопировать в буфер обмена"]').displayed? }
      rescue Selenium::WebDriver::Error::TimeoutError
        driver.find_element(css: 'li[data-tm*="phone"]').click
      end
      begin
        driver.find_element(css: '.pointer[title="Скопировать в буфер обмена"]').click
      rescue Selenium::WebDriver::Error::ElementNotInteractableError
        wait.until { driver.find_element(css: '.pointer[title="Скопировать в буфер обмена"]').displayed? }
        driver.find_element(css: '.pointer[title="Скопировать в буфер обмена"]').click
      end

      driver.execute_script("document.querySelector('.modal-tit').appendChild(document.createElement('input'))")

      elem = driver.find_element(css: '.modal-tit input')
      elem.click
      elem.send_keys([:command, 'v'])

      @phone = elem.attribute('value')
      # / GET PHONE

      html
    end
  end
end
