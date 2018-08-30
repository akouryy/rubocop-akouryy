# frozen_string_literal: true

require 'rubocop/cop/akouryy/redundant_parentheses_for_method_call'

module RuboCop
  module Akouryy
    ROOT_PATH = File.expand_path '../..', __dir__
    CONFIG_DEFAULT_PATH = File.expand_path 'config/default.yml', ROOT_PATH
    CONFIG = Psych.safe_load(File.read CONFIG_DEFAULT_PATH).freeze

    private_constant(*constants(false))
  end
end

require 'rubocop/akouryy/inject'
require 'rubocop/akouryy/version'
