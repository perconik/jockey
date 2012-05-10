module Jockey
  module Parsers
    class Java
      attr_reader :code, :comments

      def initialize(document)
        @document = document
        @code, @comments = parse(document)
      end

      private

      COMMENT_STATES = {
        "/" => {
          "/" => {
            :start_comment => {
              "\n" => :done
            }
          },
          "*" => {
            :start_comment => {
              "*" => {
                "/" => :done,
                :else => :up
              }
            }
          },
          :else => :up
        },
        '"' => {
          :start_code => {
            '"' => :done,
            '\\' => {
              '"' => :up
            }
          }
        }
      }

      def parse(document)
        code, comments = "", ""
        buffer = code
        state = COMMENT_STATES
        state_stack = []
        document.each_char do |char|
          case state[char]
          when nil then
            buffer << char
            if state[:else] == :up
              state = state_stack.pop
            end
          when :done then
            buffer << char
            state_stack = []
            state = COMMENT_STATES
            buffer = code
          when :up then
            buffer << char
            state = state_stack.pop
          else # non-terminal
            if state[char][:start_comment]
              buffer << char
              buffer = comments
              state_stack << state
              state = state[char][:start_comment]
            elsif state[char][:start_code]
              buffer << char
              buffer = code
              state_stack << state
              state = state[char][:start_code]
            else
              buffer << char
              state_stack << state
              state = state[char]
            end
          end
        end
        [code, comments]
      end
    end
  end
end
