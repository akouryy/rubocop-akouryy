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
      #   # Use the default cop Style/RedundantParentheses.
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
      #   foo 0, 1,
      #     a: 1,
      #     b: 2
      #   foo \
      #     0,
      #     a: 1,
      #     b: 2
      #
      # @example AllowInMultilineCall: always
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
      #   foo 0, 1,
      #     a: 1,
      #     b: 2
      #   foo \
      #     0,
      #     a: 1,
      #     b: 2
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

        MULTILINE_CONFIG_NAME = 'AllowInMultilineCall'
        MULTILINE_CONFIG_VALUES = %i[never before_newline always].freeze

        def on_send node
          return unless node.parenthesized_call?
          return if parens_allowed? node
          add_offense node
        end

        private def allow_in_multiline_call
          @allow_in_multiline_call ||=
            cop_config[MULTILINE_CONFIG_NAME].to_sym.tap do |a|
              unless MULTILINE_CONFIG_VALUES.include? a
                raise "Unknown option: #{a} for #{MULTILINE_CONFIG_NAME}"
              end
            end
        end

        private def_node_matcher :dot_receiver?, <<~PAT
          ^[
            (send
              equal?(%0)
              $_
              ...)
            dot?
          ]
        PAT

        private def high_method_operand? node
          high_method_operator_receiver?(node) || high_method_operator_arg?(node)
        end

        private def_node_matcher :high_method_operator_arg?, <<~PAT
          ^[
            (send
              !nil?
              #high_operator?
              equal?(%0))
            !dot?
          ]
        PAT

        private def_node_matcher :high_method_operator_receiver?, <<~PAT
          ^[
            (send
              equal?(%0)
              #high_operator?
              ...)
            !dot?
          ]
        PAT

        private def high_operand? node
          high_method_operand?(node) || high_special_operand?(node)
        end

        private def high_operator? op
          HIGH_OPERATORS.include? op.to_sym
        end

        private def high_special_operand? node
          op =
            case
            when node.irange_type? then '..'
            when node.erange_type? then '...'
            when special_operand?(node) then node.operator
            end
          op && high_operator?(op)
        end

        private def_node_matcher :non_final_arg?, <<~PAT
          ^(send
            !equal?(%0)
            _
            ...               #{'%0 is here' * 0}
            !equal?(%0))
        PAT

        private def parens_allowed? node
          dot_receiver?(node) || high_operand?(node) || non_final_arg?(node) ||
            splat_like?(node) || with_arg_s_and_brace_block?(node)
        end

        private def_node_matcher :special_operand?, '^({and or} ...)'

        private def_node_matcher :splat_like?, '^({splat kwsplat block_pass} equal?(%0))'

        private def_node_matcher :with_arg_s_and_brace_block?, <<~PAT
          [
            (send _ _ _ ...)  #{'>=1 args' * 0}
            ^[
              (block ...)
              braces?
            ]
          ]
        PAT
      end
    end
  end
end
