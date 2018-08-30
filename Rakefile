# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:spec_html) do |t|
  t.rspec_opts = '--format html --out log/rspec.html --no-color'
end

task default: :spec
task h: :spec_html
