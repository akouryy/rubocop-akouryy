# frozen_string_literal: true

# Forked from:
#   airbnb/ruby https://github.com/airbnb/ruby/blob/3b049d7523ffd530fcb8005732ff217d4de578d8/rubocop-airbnb/lib/rubocop/airbnb/inject.rb
#   (c) 2012 Airbnb
#   MIT License https://github.com/airbnb/ruby/blob/master/rubocop-airbnb/LICENSE.md

require 'yaml'

module RuboCop
  module Akouryy # :nodoc:
    # Because RuboCop doesn't yet support plugins, we have to monkey patch in a
    # bit of our configuration.
    def self.inject_defaults!
      path = CONFIG_DEFAULT_PATH
      hash = ConfigLoader.load_file(path).to_hash
      config = Config.new(hash, path)
      puts "configuration from #{path}" if ConfigLoader.debug?
      config = ConfigLoader.merge_with_default(config, path)
      File.write File.expand_path('log/debug', ROOT_PATH), config.inspect
      ConfigLoader.instance_variable_set(:@default_configuration, config)
    end
  end
end
