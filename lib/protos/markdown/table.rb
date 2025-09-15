# frozen_string_literal: true

module Protos
  class Markdown
    class Table < Protos::Table
      option :inside_header, default: -> { true }, reader: false
      option :sanitize, default: -> { true }

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
        row do
          visit_children(node)
        end

        @inside_header = false
      end

      def visit_code(node)
        code { node.string_content }
      end

      def visit_strong(node)
        strong { visit_children(node) }
      end

      def visit_emph(node)
        em { visit_children(node) }
      end

      def visit_html_inline(node)
        return if @sanitize

        raw safe(node.to_html(options: { render: { unsafe: true } }))
      end

      def visit_link(node)
        a(href: node.url, title: node.title) { visit_children(node) }
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
