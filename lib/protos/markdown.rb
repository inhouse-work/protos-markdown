# frozen_string_literal: true

require "protos"
require "markly"
require "rouge"

require_relative "markdown/ast"

module Protos
  class Markdown < ::Protos::Component # rubocop:disable Metrics/ClassLength
    param :content, reader: false
    option :sanitize, default: -> { true }, reader: false

    def view_template
      return unless root

      root.accept(self)
    end

    def visit_document(_node)
      # Do nothing
    end

    def visit_softbreak(_node)
      whitespace
    end

    def visit_text(node)
      plain(node.string_content)
    end

    def visit_header(node)
      case node.header_level
      in 1 then h1 { visit_children(node) }
      in 2 then h2 { visit_children(node) }
      in 3 then h3 { visit_children(node) }
      in 4 then h4 { visit_children(node) }
      in 5 then h5 { visit_children(node) }
      in 6 then h6 { visit_children(node) }
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
      when :ordered_list then ol { visit_children(node) }
      when :bullet_list then ul { visit_children(node) }
      end
    end

    def visit_list_item(node)
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
            unsafe_raw lex(node.string_content, node.fence_info)
          end
        end
      end
    end

    def visit_hrule(_node)
      hr
    end

    def visit_blockquote(node)
      blockquote { visit_children(node) }
    end

    def visit_html(node)
      return if @sanitize

      unsafe_raw(node.string_content)
    end

    def visit_inline_html(node)
      return if @sanitize

      unsafe_raw(node.string_content)
    end

    private

    def root
      AST.parse(@content)
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

    def code_block(code, language, **attributes) # rubocop:disable Lint/UnusedMethodArgument, Metrics/ParameterLists
      yield(**attributes)
    end

    def visit_children(node)
      node.each { |child| child.accept(self) }
    end
  end
end
