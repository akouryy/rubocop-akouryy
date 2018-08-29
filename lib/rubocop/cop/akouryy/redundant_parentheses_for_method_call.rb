# frozen_string_literal: true
require 'set'

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
        # https://docs.ruby-lang.org/ja/latest/doc/spec=2foperator.html
        HIGH_OPERATORS = %i[
          ! +@ -@ ~
          **
          + - * / %
          & | ^ << >>
          == != < <= > >= === <=> =~ !~
          && ||
          .. ...
        ].to_set

        MSG = 'Do not use unnecessary parentheses for method calls.'

        def on_send node
          return unless node.parenthesized_call?
          return if parens_allowed? node
          add_offense node
        end

        private def dot_receiver? node
          (send, = receiver? node) && send.loc.dot
        end

        private def high_operand? node
          splat_like?(node) ||
            (op = method_operand_op(node) || special_operand_op(node)) && high_operator?(op)
        end

        private def high_operator? op
          HIGH_OPERATORS.include? op
        end

        private def method_operand_op node
          send, op = receiver?(node) || sole_arg_with_receiver?(node)
          send && !send.loc.dot && op
        end

        private def_node_matcher :non_final_arg?, '^$(send _ _ ... #not_equal?(%0))'

        private def not_equal? x, y; !x.equal?(y) end

        private def not_nil? x; !x.nil? end

        private def parens_allowed? node
          dot_receiver?(node) || high_operand?(node) || non_final_arg?(node) ||
            with_arg_s_and_brace_block?(node)
        end

        private def_node_matcher :receiver?, '^$(send equal?(%0) $_ ...)'

        private def_node_matcher :sole_arg_with_receiver?, '^$(send #not_nil? $_ equal?(%0))'

        private def_node_matcher :special_operand?, '^({and or} ...)'

        private def_node_matcher :splat_like?, '^({splat kwsplat block_pass} equal?(%0))'

        private def special_operand_op node
          return :'..' if node.irange_type?
          return :'...' if node.erange_type?
          special_operand?(node) && node.operator.to_sym
        end

        private def with_arg_s_and_brace_block? node
          node.arguments.size > 0 && node.parent && node.parent.block_type? && node.parent.braces?
        end
      end
    end
  end
end
