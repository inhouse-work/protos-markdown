# frozen_string_literal: true

require "protos"
require "commonmarker"
require "rouge"
require "delegate"

require_relative "markdown/ast"
require_relative "markdown/table"

module Protos
  class Markdown < ::Protos::Component # rubocop:disable Metrics/ClassLength
    param :content, reader: false
    option :sanitize, default: -> { true }, reader: false
    option :markdown_options, default: -> { {} }, reader: false

    Heading = Data.define(:node) do
      def id
        text.downcase.gsub(/[^a-z0-9]+/, "-").chomp("-")
      end

      def text
        buffer = +""
        node.walk do |node|
          buffer << node.string_content
        rescue TypeError
          # Ignore non-text nodes
        end
        buffer
      end

      def header_level
        node.header_level
      end
    end

    def view_template
      return unless root

      root.accept(self)
    end

    def visit_document(_node)
      # Do nothing
    end

    def visit_linebreak(_node)
      br
    end

    def visit_table(node)
      render Markdown::Table.new do |table|
        node.accept(table)
      end
    end

    def visit_softbreak(_node)
      whitespace
    end

    def visit_text(node)
      plain(node.string_content)
    end

    def visit_heading(node)
      heading = Heading.new(node)

      case heading.header_level
      in 1 then h1(id: heading.id) { visit_children(node) }
      in 2 then h2(id: heading.id) { visit_children(node) }
      in 3 then h3(id: heading.id) { visit_children(node) }
      in 4 then h4(id: heading.id) { visit_children(node) }
      in 5 then h5(id: heading.id) { visit_children(node) }
      in 6 then h6(id: heading.id) { visit_children(node) }
      end
    end

    def visit_paragraph(node)
      grandparent = node.parent&.parent

      if grandparent&.type == :list && grandparent&.list_tight
        visit_children(node)
      else
        p { visit_children(node) }
      end
    end

    def visit_link(node)
      a(href: node.url, title: node.title) { visit_children(node) }
    end

    def visit_image(node)
      img(
        src: node.url,
        alt: node.each.first.string_content,
        title: node.title
      )
    end

    def visit_emph(node)
      em { visit_children(node) }
    end

    def visit_strong(node)
      strong { visit_children(node) }
    end

    def visit_list(node)
      case node.list_type
      when :ordered then ol { visit_children(node) }
      when :bullet then ul { visit_children(node) }
      else raise ArgumentError, "Unknown list type: #{node.list_type}"
      end
    end

    def visit_item(node)
      li { visit_children(node) }
    end

    def visit_code(node)
      inline_code do |**attributes|
        code(**attributes) { plain(node.string_content) }
      end
    end

    def visit_code_block(node)
      code_block(node.string_content, node.fence_info) do |**attributes|
        pre(**attributes) do
          code(class: "highlight language-#{node.fence_info}") do
            raw safe(lex(node.string_content, node.fence_info))
          end
        end
      end
    end

    def visit_thematic_break(_node)
      hr
    end

    def visit_block_quote(node)
      blockquote { visit_children(node) }
    end

    def visit_html(node)
      return if @sanitize

      raw safe(node.string_content)
    end

    def visit_html_inline(node)
      return if @sanitize

      raw safe(node.to_html(options: { render: { unsafe: true } }))
    end

    def visit_html_block(_node)
      nil
    end

    def visit_escaped(node)
      plain(node.first_child&.string_content)
    end

    private

    def root
      AST.parse(@content, markdown_options: @markdown_options)
    end

    def formatter
      @formatter ||= Rouge::Formatters::HTML.new
    end

    def lex(source, language)
      lexer = Rouge::Lexer.find(language)
      return source if lexer.nil?

      formatter.format(lexer.lex(source))
    end

    def inline_code(**attributes)
      yield(**attributes)
    end

    def code_block(code, language, **attributes) # rubocop:disable Lint/UnusedMethodArgument
      yield(**attributes)
    end

    def visit_children(node)
      node.each { |child| child.accept(self) }
    end
  end
end
