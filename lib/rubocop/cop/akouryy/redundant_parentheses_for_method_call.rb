# frozen_string_literal: true

module RuboCop
  module Cop
    module Akouryy
      # This cop checks for all omittable parentheses in method calls.
      #
      # @example
      #   # bad
      #   foo()
      #   foo(0, 1)
      #   foo(0 + 1)
      #   foo(0, *a)
      #   foo(0, a: 1, b: 2)
      #   foo bar(0, 1)
      #   foo(bar 0, 1)
      #   foo(0) do end
      #   foo(/a/)
      #   foo(%w[a b c])
      #   foo(<<~STR)
      #     heredoc
      #   STR
      #
      #   # good
      #   foo
      #   foo 0, 1
      #   foo 0 + 1
      #   foo 0, *a
      #   foo 0, a: 1, b: 2
      #   foo bar 0, 1
      #   foo 0 do end
      #   foo /a/
      #   foo %w[a b c]
      #   foo <<~STR
      #     heredoc
      #   STR
      #
      #   # good
      #   # Parentheses are required.
      #   -foo(0)
      #   foo(0) + 1
      #   foo(0).bar
      #   foo(0){}
      #   foo bar(0), 1
      #   foo bar(0) do end
      #
      #   # good
      #   # Parentheses are not part of method call.
      #   # Use the default cop Style/RedundantParentheses to prohibit these.
      #   foo (0)
      #   foo (0 + 1)
      #   foo (bar 0), 1
      #
      # @example AllowInMultilineCall: never
      #   # bad
      #   foo(0, 1,
      #     a: 2,
      #     b: 3,
      #   )
      #   foo(
      #     0,
      #     a: 1,
      #     b: 2,
      #   )
      #
      #   # good
      #   foo 0, 1,
      #     a: 1,
      #     b: 2
      #   foo \
      #     0,
      #     a: 1,
      #     b: 2
      #
      # @example AllowInMultilineCall: before_newline (default)
      #   # bad
      #   foo(0, 1,
      #     a: 2,
      #     b: 3,
      #   )
      #
      #   # good
      #   foo(
      #     0,
      #     a: 1,
      #     b: 2,
      #   )
      #
      # @example AllowBeforeNewline: always
      #   # good
      #   foo(0, 1,
      #     a: 2,
      #     b: 3,
      #   )
      #   foo(
      #     0,
      #     a: 1,
      #     b: 2,
      #   )
      class RedundantParenthesesForMethodCall < Cop
        MSG = 'Do not use unnecessary parentheses for method calls.'

        def on_send node
          return unless node.parenthesized_call?
          add_offense node
        end
      end
    end
  end
end
