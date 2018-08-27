# Forked from:
#   https://github.com/rubocop-hq/rubocop/blob/00fe34e08f680ae7e45f78bfe27c453cc12bb44a/spec/rubocop/cop/style/method_call_without_args_parentheses_spec.rb
#   (c) 2012-18 Bozhidar Batsov
#   MIT License https://github.com/rubocop-hq/rubocop/blob/master/LICENSE.txt

describe RuboCop::Cop::Akouryy::RedundantParenthesesForMethodCall do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new config }

  context 'without args' do
    it 'registers an offense for parens' do
      expect_offense <<~RUBY
        foo()
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end
  end

  context 'with single-line args' do
    it 'registers an offense for parens with simple arguments' do
      expect_offense <<~RUBY
        foo(0, 1)
           ^ Do not use unnecessary parentheses for method calls.
        foo(0 + 1)
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with splat operators' do
      expect_offense <<~RUBY
        foo(0, *a)
           ^ Do not use unnecessary parentheses for method calls.
        foo(0, **a)
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with keyword args' do
      expect_offense <<~RUBY
        foo(0, a: 1, b: 2)
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with blocks' do
      expect_offense <<~RUBY
        foo(0, &:a)
           ^ Do not use unnecessary parentheses for method calls.

        foo(0) do end
           ^ Do not use unnecessary parentheses for method calls.

        foo(){}
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'accepts parens for method calls followed by syntax with higher precedence' do
      expect_no_offenses <<~RUBY
        foo(0).bar
        foo(0){}
        foo bar(0), 1
      RUBY
    end
  end
end
