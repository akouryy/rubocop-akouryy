# RuboCop::Expert [![Gem](https://img.shields.io/gem/v/rubocop-expert.svg?logo=ruby&logoColor=ff1111&colorA=404040)](https://rubygems.org/gems/rubocop-expert)

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?logo=github&logoColor=ffffff&colorA=404040)](LICENSE.txt)
![Ruby Versions](https://img.shields.io/badge/Ruby-2.3_--_2.5-red.svg?logo=ruby&colorA=404040)
[![Travis CI](https://img.shields.io/travis/akouryy/rubocop-expert.svg?logo=travis&colorA=404040)](https://travis-ci.org/akouryy/rubocop-expert)
[![Maintainability](https://img.shields.io/codeclimate/maintainability-percentage/akouryy/rubocop-expert.svg?colorA=404040&logoColor=ffffff)](https://codeclimate.com/github/akouryy/rubocop-expert/maintainability)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/akouryy/rubocop-expert.svg?colorA=404040&logoColor=ffffff)](https://codeclimate.com/github/akouryy/rubocop-expert/test_coverage)

[RuboCop](https://github.com/rubocop-hq/rubocop/) custom cops for elegance.

* [Cops](#cops)
  * [RedundantParenthesesForMethodCall](#redundantparenthesesformethodcall)
* [Installation and Usage](#installation-and-usage)
* [License](#license)

## Cops

### RedundantParenthesesForMethodCall

This cop checks for any *redundant* parentheses for method calls even with arguments.
```ruby
# bad
foo(/a/, *b)
# good
foo /a/, *b
```

For more information and examples, refer to the documentation comment in [redundant_parentheses_for_method_call.rb](lib/rubocop/cop/expert/redundant_parentheses_for_method_call.rb).

## Installation and Usage

Add this line to Gemfile:

```ruby
gem 'rubocop-expert'
```

Require this gem in .rubocop.yml:

```yaml
require:
  - rubocop-expert
```

Now you can check your code with:

```sh
$ rubocop
```

## Development

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akouryy/rubocop-expert.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
