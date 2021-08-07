module AutoRia
  class StatusUpdater
    include Sidekiq::Worker

    sidekiq_options queue: 'provider-ads-status', retry: true, backtrace: false

    STATUSES = %w[failed deleted completed].freeze

    def perform(message)
      message = JSON.parse(message).with_indifferent_access

      status = message[:status].to_s.downcase
      address = message[:address].to_s.downcase

      if STATUSES.include?(status)
        Url.where(address: address).update(status: status)
        logger.info("[AutoRia::StatusUpdater][#{status}][#{address}] #{message[:errors]}")
      else
        logger.info("[AutoRia::StatusUpdater][UnknownStatus] #{status}")
      end
    end
  end
end
