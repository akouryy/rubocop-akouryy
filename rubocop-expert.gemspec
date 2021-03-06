# frozen_string_literal: true

lib = File.expand_path 'lib', __dir__
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib
require 'rubocop/expert/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-expert'
  spec.version = RuboCop::Expert::VERSION
  spec.authors = ['akouryy']
  spec.email = ['akouryy7@gmail.com']

  spec.summary = 'RuboCop custom cops for elegance'
  spec.description = <<~DESC
    RuboCop custom cops for elegance.
    At the moment there is only one cop: Expert/RedundantParenthesesForMethodCall.
  DESC
  spec.homepage = 'https://github.com/akouryy/rubocop-expert'
  spec.license = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir __dir__ do
    `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rubocop', '~> 0.58.2'
  spec.add_dependency 'rubocop-rspec', '~> 1.29.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry-byebug', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
