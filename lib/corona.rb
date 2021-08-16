# frozen_string_literal: true

ENV['CORONA_ENV'] ||= 'development'

require 'yaml'
require 'erb'
require 'rubygems'
require 'bundler/setup'
require 'zeitwerk'
require 'logger'
require 'sequel'
require 'dotenv'
require 'active_support/all'
require 'open-uri'

class Corona
  class << self
    def mount_auto_loader!
      Dir.glob("#{root}/app/*").select { |fn| File.directory?(fn) }.each { |dir| loader.push_dir(dir) }
      loader.enable_reloading if development?
      loader.setup
    end

    def env
      ENV['CORONA_ENV'].strip
    end

    def development?
      env == 'development'
    end

    def test?
      env == 'test'
    end

    def production?
      env == 'production'
    end

    def logger
      @logger ||= Logger.new($stdout)
    end

    def config
      OpenStruct.new(database: YAML.safe_load(ERB.new(File.read("#{root}/config/database.yml")).result)[env])
    end

    def root
      File.expand_path('..', __dir__)
    end

    def reload!
      development? ? @loader.reload : false
    end

    private

    def loader
      @loader ||= Zeitwerk::Loader.new
    end
  end
end
