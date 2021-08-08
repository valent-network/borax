module AutoRia
  class StatusUpdater
    include Sidekiq::Worker

    sidekiq_options queue: 'provider-ads-status', retry: true, backtrace: false

    STATUSES = %w[failed deleted completed].freeze

    def perform(message)
      message = JSON.parse(message)

      status = message['status'].to_s.downcase
      address = message['address'].to_s.downcase
      errors = message['errors']

      if STATUSES.include?(status)
        Url.where(address: address).update(status: status)
        logger.info("[AutoRia::StatusUpdater][#{status}][#{address}] #{errors}")
      else
        logger.info("[AutoRia::StatusUpdater][UnknownStatus] #{status}")
      end
    end
  end
end
