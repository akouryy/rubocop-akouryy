# frozen_string_literal: true

# Forked from:
#   rubocop-hq/rubocop https://github.com/rubocop-hq/rubocop/blob/00fe34e08f680ae7e45f78bfe27c453cc12bb44a/spec/rubocop/cop/style/method_call_without_args_parentheses_spec.rb
#   (c) 2012-18 Bozhidar Batsov
#   MIT License https://github.com/rubocop-hq/rubocop/blob/master/LICENSE.txt

describe RuboCop::Cop::Expert::RedundantParenthesesForMethodCall, :config do
  subject(:cop) { described_class.new config }
  let(:ruby_version) { RUBY_VERSION.to_f }
  lonely = RUBY_VERSION.to_f >= 2.5
  let(:lonely) { RUBY_VERSION.to_f >= 2.5 }

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

    it 'registers an offense for parens in an operator expr' do
      expect_offense <<~RUBY
        foo() + 1
           ^ Do not use unnecessary parentheses for method calls.
        foo() and 1
           ^ Do not use unnecessary parentheses for method calls.
        foo() ? bar() : baz()
           ^ Do not use unnecessary parentheses for method calls.
                   ^ Do not use unnecessary parentheses for method calls.
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
        foo(a ? b : c)
           ^ Do not use unnecessary parentheses for method calls.
        bar.
          foo(0 + 1)
             ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    if lonely
      it 'registers an offense for parens with simple lonely method arguments' do
        expect_offense <<~RUBY
          bar&.foo(1)
                  ^ Do not use unnecessary parentheses for method calls.
        RUBY
      end
    end

    it 'registers an offense for parens with an argument which itself needs parens' do
      expect_offense <<~RUBY
        foo((a and b))
           ^ Do not use unnecessary parentheses for method calls.
        foo((a or b))
           ^ Do not use unnecessary parentheses for method calls.
        foo((a/b rescue 0))
           ^ Do not use unnecessary parentheses for method calls.
        foo((a if b))
           ^ Do not use unnecessary parentheses for method calls.
        foo((a while b))
           ^ Do not use unnecessary parentheses for method calls.
        foo((a; b))
           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens of a call as the operand of' \
        ' a binary operator with low precedence' do
      expect_offense <<~RUBY
        0 and foo(1)
                 ^ Do not use unnecessary parentheses for method calls.
        foo(0) or 1
           ^ Do not use unnecessary parentheses for method calls.
        not foo(0)
               ^ Do not use unnecessary parentheses for method calls.
        foo(0) rescue bar(1)
           ^ Do not use unnecessary parentheses for method calls.
                         ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offense for parens with splat operators' do
      expect_offense <<~RUBY
        foo(0, *a)
           ^ Do not use unnecessary parentheses for method calls.
        "#\{foo(0, **a)}"
          \    ^ Do not use unnecessary parentheses for method calls.
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

    it 'registers an offence for parens of a call as a single argument of another call' do
      expect_offense <<~RUBY
        foo bar(0)
               ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offence for parens of a call as a single element of assoc bracket' do
      expect_offense <<~RUBY
        foo[bar(0)]
               ^ Do not use unnecessary parentheses for method calls.

        foo[bar(0, 1)] = baz
               ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offence for parens of a method call as'\
        ' the single expr of a method call-like syntax' do
      expect_offense <<~RUBY
        return foo(0, 1)
                  ^ Do not use unnecessary parentheses for method calls.
        next foo(0, 1)
                ^ Do not use unnecessary parentheses for method calls.
        break foo(0, 1)
                 ^ Do not use unnecessary parentheses for method calls.
        super foo(0, 1)
                 ^ Do not use unnecessary parentheses for method calls.
        raise foo(0, 1)
                 ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offence for parens of a call as a if-stmt condition' do
      expect_offense <<~RUBY
        if foo(0, 1)
              ^ Do not use unnecessary parentheses for method calls.
        elsif bar(2, *3)
                 ^ Do not use unnecessary parentheses for method calls.
        end
      RUBY
    end

    it 'registers an offence for parens of a call as a for-stmt enumerable' do
      expect_offense <<~RUBY
        for a in foo(0, 1); end
                    ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offence for parens of a call as a while-stmt condition' do
      expect_offense <<~RUBY
        while foo(0, 1); end
                 ^ Do not use unnecessary parentheses for method calls.
        begin end while foo(0, 1)
                           ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offence for parens of a call as a case-stmt subject' do
      expect_offense <<~RUBY
        case foo(0, 1); when nil; end
                ^ Do not use unnecessary parentheses for method calls.
      RUBY
    end

    it 'registers an offence for parens of a call as a superclass' do
      expect_offense <<~RUBY
        class A < foo(B); end
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
          foo[**bar(0)]
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

      it 'accepts parens for a method call that is an operand of a ternary operator' do
        expect_no_offenses <<~RUBY
          foo(0) ? bar(1) : baz(2)
          a ? b = foo(0) : c
          a ? b : c = foo(0)
          a ? b **= foo(0) : c
        RUBY
      end

      it 'accepts parens for method calls followed by dot' do
        expect_no_offenses <<~RUBY
          foo(0).bar
          #{'foo(0)&.bar' if lonely}
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
          #{'foo&.(0)' if lonely}
        RUBY
      end

      it 'accepts parens for a method call that is among multiple args of other method calls' do
        expect_no_offenses <<~RUBY
          foo bar(0), 1
          baz.foo bar(0), 1
          #{'baz&.foo bar(0), 1' if lonely}
          foo 0, 1, bar(2)
          foo 0, bar(1), *baz
        RUBY
      end

      it 'accepts parens for a method call among multiple exprs of a method call-like syntax' do
        expect_no_offenses <<~RUBY
          return 0, foo(1)
          return foo(0), 1
          break 0, foo(1)
          next foo(0), 1
          super 0, foo(1), *a
          raise foo(0), 1
          # yield foo(0), 1, **a
        RUBY
      end

      it 'accepts parens for a call among multiple elements of assoc bracket' do
        expect_no_offenses <<~RUBY
          foo[bar(0), 1]

          foo[0, bar(1)] = baz
        RUBY
      end

      it 'accepts parens for method calls in right hand side of multi-assignment' do
        expect_no_offenses <<~RUBY
          a = 0, foo(1)
        RUBY
      end

      it 'accepts parens for method calls in array brackets or hash braces' do
        expect_no_offenses <<~RUBY
          [foo(0)]
          { foo: bar(0) }
          { foo(0) => bar }
          foo bar: baz(0)
        RUBY
      end

      it 'accepts parens for method calls in when condition' do
        expect_no_offenses <<~RUBY
          case 0; when foo(1); end
        RUBY
      end

      it 'accepts parens for a call as error type to rescue' do
        expect_no_offenses <<~RUBY
          begin rescue foo(0); end
          begin rescue foo(0) => e; end
        RUBY
      end

      it 'accepts parens for a method call as the default of an optional parameter' do
        expect_no_offenses <<~RUBY
          def foo a = bar(0); end
          def foo a: baz(1); end
          foo do |a = bar(0), b: baz(1)| end
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

      if lonely
        it 'registers an offense for parens of lonely method call' do
          expect_offense <<~RUBY
            (foo(0))&.bar
                ^ Do not use unnecessary parentheses for method calls.
          RUBY
        end
      end
    end

    it 'registers an offence for parens of a call in parenthesized assignment' do
      expect_offense <<~RUBY
        a ? (b = foo(0)) : c
                    ^ Do not use unnecessary parentheses for method calls.
        a ? b : (c = foo(0))
                        ^ Do not use unnecessary parentheses for method calls.
        a ? (b **= foo(0)) : c
                      ^ Do not use unnecessary parentheses for method calls.
      RUBY
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
