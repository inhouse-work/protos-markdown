# frozen_string_literal: true

module Protos
  class Markdown < ::Protos::Component
    class AST
      class Node < SimpleDelegator
        def accept(visitor)
          visitor.send(:"visit_#{type}", self)
        end

        def each(&block)
          return enum_for(:each) unless block

          super do |child|
            yield Node.new(child)
          end
        end
      end

      def self.parse(content, markdown_options: {})
        options = {
          render: { gfm_quirks: true },
          extension: { table: true },
          **markdown_options
        }

        Commonmarker
          .parse(content, options:)
          .then { |node| new(Node.new(node)) }
      end

      def initialize(root)
        @root = root
      end

      def accept(visitor)
        @root.each do |node|
          Node.new(node).accept(visitor)
        end
      end
    end
  end
end
