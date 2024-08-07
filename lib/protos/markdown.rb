# frozen_string_literal: true

require "protos"
require "markly"
require "rouge"

module Protos
  class Markdown < Protos::Component
    param :content, reader: false

    def view_template
      visit(doc)
    end

    private

    def doc
      Markly.parse(@content)
    end

    def visit(node) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      return if node.nil?

      case node.type
      in :document
        visit_children(node)
      in :softbreak
        whitespace
        visit_children(node)
      in :text
        plain(node.string_content)
      in :header
        case node.header_level
        in 1 then h1 { visit_children(node) }
        in 2 then h2 { visit_children(node) }
        in 3 then h3 { visit_children(node) }
        in 4 then h4 { visit_children(node) }
        in 5 then h5 { visit_children(node) }
        in 6 then h6 { visit_children(node) }
        end
      in :paragraph
        grandparent = node.parent&.parent

        if grandparent&.type == :list && grandparent&.list_tight
          visit_children(node)
        else
          p { visit_children(node) }
        end
      in :link
        a(href: node.url, title: node.title) { visit_children(node) }
      in :image
        img(
          src: node.url,
          alt: node.each.first.string_content,
          title: node.title
        )
      in :emph
        em { visit_children(node) }
      in :strong
        strong { visit_children(node) }
      in :list
        case node.list_type
        in :ordered_list then ol { visit_children(node) }
        in :bullet_list then ul { visit_children(node) }
        end
      in :list_item
        li { visit_children(node) }
      in :code
        inline_code do |**attributes|
          code(**attributes) { plain(node.string_content) }
        end
      in :code_block
        code_block(node.string_content, node.fence_info) do |**attributes|
          pre(**attributes) do
            code(class: "highlight language-#{node.fence_info}") do
              unsafe_raw lex(node.string_content, node.fence_info)
            end
          end
        end
      in :hrule
        hr
      in :blockquote
        blockquote { visit_children(node) }
      in :html
        unsafe_raw(node.string_content)
      else
        raise StandardError, "Unknown node type: #{node.type}"
      end
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
      node.each { |c| visit(c) }
    end
  end
end
