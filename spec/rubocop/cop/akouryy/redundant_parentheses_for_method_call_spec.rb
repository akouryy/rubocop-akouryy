# frozen_string_literal: true

# Forked from:
#   rubocop-hq/rubocop https://github.com/rubocop-hq/rubocop/blob/00fe34e08f680ae7e45f78bfe27c453cc12bb44a/spec/rubocop/cop/style/method_call_without_args_parentheses_spec.rb
#   (c) 2012-18 Bozhidar Batsov
#   MIT License https://github.com/rubocop-hq/rubocop/blob/master/LICENSE.txt

describe RuboCop::Cop::Akouryy::RedundantParenthesesForMethodCall, :config do
  subject(:cop) { described_class.new config }

  context 'without args' do
    it 'registers an offense for parens' do
      expect_offense <<~RUBY
        foo()
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with brace block' do
      expect_offense <<~RUBY
        foo(){}
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with do block' do
      expect_offense <<~RUBY
        foo() do end
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end
  end

  context 'with single-line args' do
    it 'registers an offense for parens with simple arguments' do
      expect_offense <<~RUBY
        foo(0, 1)
           ^ Do not use unnecessary parentheses for method calls.
        foo(a = 1)
           ^ Do not use unnecessary parentheses for method calls.
        bar.
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
      RUBY
    end

    it 'registers an offence for parens of a method call in single-value return' do
      expect_offense <<~RUBY
        return foo(0, 1)
                  ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offence for parens of a call as a for-stmt enumerable' do
      expect_offense <<~RUBY
        for a in foo(0, 1); end
                    ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    context 'when method call is not inside parens' do
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
          foo(0) && 3
          4 || foo(0)
          foo(0)..5
          6...foo(0)
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

      it 'accepts parens for special call syntax of method named \'call\'' do
        expect_no_offenses <<~RUBY
          foo.(0)
        RUBY
      end

      it 'accepts parens for a method call that is among multiple args of other method calls' do
        expect_no_offenses <<~RUBY
          foo bar(0), 1
          foo 0, 1, bar(2)
          foo 0, bar(1), *baz
        RUBY
      end

      it 'accepts parens for method calls in right hand side of multi-assignment' do
        expect_no_offenses <<~RUBY
          a = 0, foo(1)
        RUBY
      end

      it 'accepts parens for method calls in multiple return' do
        expect_no_offenses <<~RUBY
          return 0, foo(1)
          return foo(0), 1
        RUBY
      end

      it 'accepts parens for method calls in array brackets or hash braces' do
        expect_no_offenses <<~RUBY
          [foo(0)]
          { foo: bar(0) }
          foo bar: baz(0)
        RUBY
      end

      it 'accepts parens for method calls in when condition' do
        expect_no_offenses <<~RUBY
          case 0; when foo(1); end
        RUBY
      end

      it 'accepts parens for a method call as the default of an optional parameter' do
        expect_no_offenses <<~RUBY
          def foo a = bar(0); end
          def foo a: baz(1); end
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

    context 'when method call is inside parens' do
      it 'registers an offense for parens of method call' do
        expect_offense <<~RUBY
          +(foo(0))
               ^ Do not use unnecessary parentheses for method calls.
          foo *(bar(0))
                   ^ Do not use unnecessary parentheses for method calls.
          1 + (foo(0))
                  ^ Do not use unnecessary parentheses for method calls.
          (foo(0)).bar
              ^ Do not use unnecessary parentheses for method calls.
          (foo(0))[1, 2]
              ^ Do not use unnecessary parentheses for method calls.
          foo (bar(0)), 1
                  ^ Do not use unnecessary parentheses for method calls.
          foo 0, (bar(1)), 2
                     ^ Do not use unnecessary parentheses for method calls.
          [(foo(0))]
               ^ Do not use unnecessary parentheses for method calls.
          case 0; when(foo(1)); end
                          ^ Do not use unnecessary parentheses for method calls.
          def foo a = (bar(0)); end
                          ^ Do not use unnecessary parentheses for method calls.
        RUBY
      end
    end
  end

  context 'with multiline args' do
    context 'when AllowInMultilineCall is \'never\'' do
      let(:cop_config) { { 'AllowInMultilineCall' => 'never' } }

      it 'registers an offense for parens with multiline args' \
          ' the first of which is in the same line' do
        expect_offense <<~RUBY
          foo(0,
             ^ Do not use unnecessary parentheses for method calls.
            1)
          foo(0, 1,
             ^ Do not use unnecessary parentheses for method calls.
            a: 2,
            b: 3,
          )
        RUBY
      end

      it 'registers an offense for parens followed by newline' do
        expect_offense <<~RUBY
          foo(
             ^ Do not use unnecessary parentheses for method calls.
            0,
            1)
          foo(
             ^ Do not use unnecessary parentheses for method calls.
            0, 1,
            a: 2,
            b: 3,
          )
        RUBY
      end
    end

    context 'when AllowInMultilineCall is \'before_newline\'' do
      let(:cop_config) { { 'AllowInMultilineCall' => 'before_newline' } }

      it 'registers an offense for parens with multiline args' \
          ' the first of which is in the same line' do
        expect_offense <<~RUBY
          foo(0,
             ^ Do not use unnecessary parentheses for method calls.
            1)
          foo(0, 1,
             ^ Do not use unnecessary parentheses for method calls.
            a: 2,
            b: 3,
          )
        RUBY
      end

      it 'accepts parens followed by newline' do
        expect_no_offenses <<~RUBY
          foo(
            0,
            1)
          foo(
            0, 1,
            a: 2,
            b: 3,
          )
        RUBY
      end
    end

    context 'when AllowInMultilineCall is \'always\'' do
      let(:cop_config) { { 'AllowInMultilineCall' => 'always' } }

      it 'accepts parens with multiline args' \
          ' the first of which is in the same line' do
        expect_no_offenses <<~RUBY
          foo(0,
            1)
          foo(0, 1,
            a: 2,
            b: 3,
          )
        RUBY
      end

      it 'accepts parens followed by newline' do
        expect_no_offenses <<~RUBY
          foo(
            0,
            1)
          foo(
            0, 1,
            a: 2,
            b: 3,
          )
        RUBY
      end
    end
  end
end
