# frozen_string_literal: true

require 'rubocop'
begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

require_relative 'rubocop/akouryy'

RuboCop::Akouryy.inject_defaults!