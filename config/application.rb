# frozen_string_literal: true

require './lib/corona'

require 'open-uri'

Bundler.require(:default, Corona.env)

Dotenv.load("#{Corona.root}/.env", "#{Corona.root}/.env.#{Corona.env}")

begin
  DB = Sequel.connect(Corona.config.database)
rescue StandardError => e
  puts "#{e.class}: #{e.message}"
end

module Urls
  class Application
  end
end
