# frozen_string_literal: true

module Protos
  class Markdown
    class Table < Protos::Table
      option :inside_header, default: -> { false }, reader: false

      def visit_table(node)
        visit_children(node)
      end

      def visit_table_header(node)
        @inside_header = true

        header do
          visit_children(node)
        end
      end

      def visit_table_cell(node)
        if @inside_header
          head { visit_children(node) }
        else
          cell { visit_children(node) }
        end
      end

      def visit_text(node)
        plain(node.string_content)
      end

      def visit_table_row(node)
        @inside_header = false

        row do
          visit_children(node)
        end
      end

      def visit_code(node)
        code { node.string_content }
      end

      def visit_strong(node)
        strong { visit_children(node) }
      end

      private

      def visit_children(node)
        node.each do |child|
          child.accept(self)
        end
      end
    end
  end
end
