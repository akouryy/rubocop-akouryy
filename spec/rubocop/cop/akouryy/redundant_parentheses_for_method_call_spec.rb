# frozen_string_literal: true

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
        ^^^^^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with brace block' do
      expect_offense <<~RUBY
        foo(){}
        ^^^^^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with do block' do
      expect_offense <<~RUBY
        foo() do end
        ^^^^^ Do not use unnecessary parentheses for method calls.
      RUBY
    end
  end

  context 'with single-line args' do
    it 'registers an offense for parens with simple arguments' do
      expect_offense <<~RUBY
        foo(0, 1)
        ^^^^^^^^^ Do not use unnecessary parentheses for method calls.
        foo(0 + 1)
        ^^^^^^^^^^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with splat operators' do
      expect_offense <<~RUBY
        foo(0, *a)
        ^^^^^^^^^^ Do not use unnecessary parentheses for method calls.
        foo(0, **a)
        ^^^^^^^^^^^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with keyword args' do
      expect_offense <<~RUBY
        foo(0, a: 1, b: 2)
        ^^^^^^^^^^^^^^^^^^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with blocks' do
      expect_offense <<~RUBY
        foo(0, &:a)
        ^^^^^^^^^^^ Do not use unnecessary parentheses for method calls.

        foo(0) do end
        ^^^^^^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'accepts parens for method calls that are operands of unary operators' do
      expect_no_offenses <<~RUBY
        +foo(0)
        -foo(0)
        !foo(0)
      RUBY
    end

    it 'accepts parens for method calls prefixed by splat-like syntaxes' do
      expect_no_offenses <<~RUBY
        foo *bar(0)
        foo **bar(0)
        foo &bar(0)
        foo = *bar(0)
      RUBY
    end

    it 'accepts parens for method calls that are operands of' \
        ' binary operators with high precedence' do
      expect_no_offenses <<~RUBY
        1 + foo(0)
        foo(0) ** 2
      RUBY
    end

    it 'accepts parens for method calls followed by dot' do
      expect_no_offenses <<~RUBY
        foo(0).bar
      RUBY
    end

    it 'accepts parens for method calls with argument(s) followed by braces' do
      expect_no_offenses <<~RUBY
        foo(0){}
      RUBY
    end

    it 'accepts parens for method calls with argument(s) followed by brackets' do
      expect_no_offenses <<~RUBY
        foo(0)[1, 2]
        foo(0)[1, 2] = 3
      RUBY
    end

    it 'accepts parens for special call syntax of method `call`' do
      expect_no_offenses <<~RUBY
        foo.(0)
      RUBY
    end

    it 'accepts parens for method calls that are non-final args of other method calls' do
      expect_no_offenses <<~RUBY
        foo bar(0), 1
        foo 0, bar(1), 2
        foo 0, bar(1), *baz
      RUBY
    end

    it 'accepts redundant parens which is not part of method calls' do
      expect_no_offenses <<~RUBY
        foo (0)
        foo (0 + 1)
        foo (bar 0), 1
      RUBY
    end
  end
end
