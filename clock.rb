require 'clockwork'

require './config/application'

Corona.mount_auto_loader!

module Clockwork
  every(1.hour, 'Crawl auto.ria.com') { AutoRia.crawl! }
  every(1.second, 'Scrape auto.ria.com') { AutoRia.scrape!(0, 2) }
  every(1.minute, 'Actualize auto.ria.com') { AutoRia.actualize! }
end
