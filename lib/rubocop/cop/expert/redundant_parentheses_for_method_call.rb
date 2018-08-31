# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Expert
      # This cop checks for all omittable parentheses in method calls.
      #
      # @example
      #   # bad
      #   foo()
      #   foo(0, 1)
      #   foo(0 + 1)
      #   foo(a = 1)
      #   foo(0, *a)
      #   foo(0, a: 1, b: 2)
      #   foo bar(0, 1)
      #   foo(bar 0, 1)
      #   foo 0, (bar(1))
      #   foo(0) do end
      #   foo(/a/)
      #   foo(%w[a b c])
      #   foo(<<~STR)
      #     heredoc
      #   STR
      #   for a in foo(0, 1); end
      #
      #   # good
      #   foo
      #   foo 0, 1
      #   foo 0 + 1
      #   foo a = 1
      #   foo 0, *a
      #   foo 0, a: 1, b: 2
      #   foo bar 0, 1
      #   foo 0, (bar 1)
      #   foo 0 do end
      #   foo /a/
      #   foo %w[a b c]
      #   foo <<~STR
      #     heredoc
      #   STR
      #   for a in foo 0, 1; end
      #
      #   # good
      #   # Parentheses are required.
      #   -foo(0)
      #   foo(0) + 1
      #   foo(0) ? bar(1) : baz(2)
      #   foo(0).bar
      #   foo(0){}
      #   foo 0, bar(1)
      #   foo bar(0), 1
      #   a = 0, foo(1) # multiple assignment
      #   foo bar(0) do end
      #   [foo(0)]
      #   { foo: bar(0) }
      #   case 0; when foo(1); end
      #   def foo a = bar(0), b: baz(1); end
      #   return 0, foo(1) # return multiple value
      #
      #   # good
      #   # Parentheses are not part of the method call.
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
          return if allowed_by_multiline_config? node
          add_offense node, location: :begin
        end

        private def allowed_by_multiline_config? node
          fn_ln = node.loc.selector&.line
          first_arg_ln = node.arguments[0]&.loc&.line
          par_end_ln = node.loc.end.line

          fn_ln && fn_ln != par_end_ln &&
            case multiline_config
            when :never
              false
            when :before_newline
              first_arg_ln && fn_ln != first_arg_ln
            when :always
              true
            end
        end

        private def_node_matcher :among_multiple_args?, <<~PAT
          ^[
            (send
              !equal?(%0)
              _
              _ _ ...)        #{'>=2 args; %0 is here' * 0}
            #fn?]
        PAT

        private def_node_matcher :among_multiple_return?, <<~PAT
          ^(return _ _ ...)   #{'>=1 values' * 0}
        PAT

        private def_node_matcher :arg_s?, '(send _ _ _ ...)' # >=1 args

        private def_node_matcher :array_element?, '^(array ...)'

        private def_node_matcher :assoc_bracket_multiple_element?, <<~PAT
          ^[
            {
              (send
                !equal?(%0)
                :[]
                _ _ ...)      #{'>=2 elements; %0 is here' * 0}
              (send
                !equal?(%0)
                :[]=
                _ _ ...       #{'>=2 elements; %0 is here' * 0}
                _)}           #{': expr after "="' * 0}
            !#fn?]
        PAT

        private def_node_matcher :bracket_receiver?, <<~PAT
          ^[
            (send
              equal?(%0)
              { :[] :[]= }
              ...)
            !#fn?
          ]
        PAT

        private def_node_matcher :default_of_optarg?, <<~PAT
          ^[
            ({optarg kwoptarg}
              _
              equal?(%0))
          ]
        PAT

        private def_node_matcher :dot_receiver?, <<~PAT
          ^[
            (send
              equal?(%0)
              $_
              ...)
            dot?
          ]
        PAT

        private def explicit_receiver? node
          bracket_receiver?(node) || dot_receiver?(node)
        end

        private def_node_matcher :fn?, <<~PAT
          {
            (send nil? ...)
            [
              (send ...)
              dot?]}
        PAT

        private def_node_matcher :hash_element?, <<~PAT
          [
            ^^(hash ...)
            ^(pair _ equal?(%0))
          ]
        PAT

        private def high_method_operand? node
          high_method_operator_receiver?(node) || high_method_operator_arg?(node)
        end

        private def_node_matcher :high_method_operator_arg?, <<~PAT
          ^[
            (send
              _
              #high_operator?
              equal?(%0))
            !#fn?
          ]
        PAT

        private def_node_matcher :high_method_operator_receiver?, <<~PAT
          ^[
            (send
              equal?(%0)
              #high_operator?
              ...)
            !#fn?
            !keyword_not?
          ]
        PAT

        private def high_operand? node
          high_method_operand?(node) || high_special_operand?(node) ||
          ternary_operand?(node)
        end

        private def high_operator? op
          HIGH_OPERATORS.include? op.to_sym
        end

        private def high_special_operand? node
          op =
            case
            when node.parent&.irange_type? then '..'
            when node.parent&.erange_type? then '...'
            when special_operand?(node) then node.parent.operator
            end
          op && high_operator?(op)
        end

        private def implicit_call? node
          node.implicit_call?
        end

        private def multiline_config
          @multiline_config ||=
            (cop_config[MULTILINE_CONFIG_NAME] || :before_newline).to_sym.tap do |a|
              unless MULTILINE_CONFIG_VALUES.include? a
                raise "Unknown option: #{MULTILINE_CONFIG_NAME}: #{a}"
              end
            end
        end

        private def parens_allowed? node
          arg_s?(node) &&
          %i[
            among_multiple_args?
            among_multiple_return?
            array_element?
            assoc_bracket_multiple_element?
            default_of_optarg?
            explicit_receiver?
            hash_element?
            high_operand?
            implicit_call?
            rescue_error_type?
            splat_like?
            when_cond?
            with_arg_s_and_brace_block?
          ].any? do |sym|
            __send__ sym, node
          end
        end

        # covered by array_element?, but check again to ensure
        private def_node_matcher :rescue_error_type?, <<~PAT
          [
            ^^(resbody ...)
            ^(array ...)]
        PAT

        private def_node_matcher :special_operand?, '^({and or} ...)'

        private def_node_matcher :splat_like?, '^({splat kwsplat block_pass} equal?(%0))'

        private def_node_matcher :ternary_operand?, <<~PAT
          {
            ^[(if ...) ternary?]
            [
              ^^[(if ...) ternary?]
              ^{
                (lvasgn _ equal?(%0))
                (op_asgn _ _ equal?(%0))}]}
        PAT

        private def_node_matcher :when_cond?, '^(when equal?(%0) _)'

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
