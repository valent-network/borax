# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "activesupport", "~> 7"
gem "dotenv", "~> 2"
gem "faraday", "~> 1"
gem "faraday_middleware", "~> 1"
gem "nokogiri", "~> 1"

# Can't upgrade to 7
# https://github.com/mhenrixon/sidekiq-unique-jobs/issues/684
gem "sidekiq", "~> 6"

gem "sidekiq-unique-jobs", "~> 7"
gem "zeitwerk", "~> 2"

gem "newrelic_rpm"

group :development do
  gem "byebug"
  gem "foreman", require: false
end
