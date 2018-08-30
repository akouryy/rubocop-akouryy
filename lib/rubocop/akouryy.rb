# frozen_string_literal: true

module RuboCop
  module Akouryy # :nodoc:
    ROOT_PATH = File.expand_path '../..', __dir__
    CONFIG_DEFAULT_PATH = File.expand_path 'config/default.yml', ROOT_PATH
    CONFIG = Psych.safe_load(File.read CONFIG_DEFAULT_PATH).freeze
  end
end

require_relative 'cop/akouryy/redundant_parentheses_for_method_call'
require_relative 'akouryy/inject'
require_relative 'akouryy/version'
