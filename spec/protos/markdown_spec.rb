# frozen_string_literal: true

require "protos/markdown"

RSpec.describe Protos::Markdown, type: :view do
  def render_markdown(content)
    render Protos::Markdown.new(content, sanitize: false)
  end

  it "handles line breaks" do
    render_markdown "Hello  \nWorld"

    expect(page).to have_css "br"
  end

  it "handles escaped characters" do
    render_markdown "Hello \\*World\\*"

    expect(page).to have_css "p", text: "Hello *World*"
  end

  it "handles html blocks" do
    render_markdown <<~MD
      <!-- This is a comment -->
    MD

    expect(page).not_to have_content "<!-- This is a comment -->"
  end

  it "supports tables" do
    render_markdown <<~MD
      |**Entity ID**|`Health`|
      |-------------|--------|
      | [1](https://google.com) |100.0   |
      | 3           |<div>40.0</div>    |
    MD

    expect(page).to have_css "table"
    expect(page).to have_css "th", text: "Entity ID"
    expect(page).to have_css "th", text: "Health"
    expect(page).to have_css "td", text: "1"
    expect(page).to have_css "td", text: "100.0"
    expect(page).to have_css "td", text: "3"
    expect(page).to have_css "td", text: "40.0"
    expect(page).to have_css "tr", count: 3
    expect(page).to have_link("1")
    expect(page).to have_css "code", text: "Health"
    expect(page).to have_css "strong", text: "Entity ID"
  end

  it "supports inline html" do
    render_markdown "I am about to say <div>Hello</div> <kbd>World</kbd>"

    expect(page).to have_css "div", text: "Hello"
    expect(page).to have_css "kbd", text: "World"
  end

  it "supports headings with links" do
    render_markdown <<~MD
      # [Introduction](/something)
    MD

    expect(page).to have_css "h1", id: "introduction"
    expect(page).to have_css "h1 a", text: "Introduction"
  end

  it "supports multiple headings" do
    render_markdown <<~MD
      # 1
      ## 2
      ### 3
      #### 4
      ##### 5
      ###### 6
    MD

    expect(page).to have_css "h1", text: "1", id: "1"
    expect(page).to have_css "h2", text: "2", id: "2"
    expect(page).to have_css "h3", text: "3", id: "3"
    expect(page).to have_css "h4", text: "4", id: "4"
    expect(page).to have_css "h5", text: "5", id: "5"
    expect(page).to have_css "h6", text: "6", id: "6"
  end

  it "supports ordered lists" do
    render_markdown <<~MD
      1. One
      2. Two
      3. Three
    MD

    expect(page).to have_css "ol"
    expect(page).to have_css "li", count: 3
  end

  it "supports unordered lists" do
    render_markdown <<~MD
      - One
      - Two
      - Three
    MD

    expect(page).to have_css "ul"
    expect(page).to have_css "li", count: 3
  end

  it "supports inline code" do
    render_markdown "Some `code` here"

    expect(page).to have_css "code", text: "code"
  end

  it "supports block code" do
    render_markdown <<~MD
      ```ruby
      def foo
      	bar
      end
      ```
    MD

    expect(page).to have_css "pre code[class='highlight language-ruby']"
    expect(page).to have_css "span.k", text: "def"
  end

  it "supports paragraphs" do
    render_markdown "A\n\nB"

    expect(page).to have_css "p", count: 2
  end

  it "supports links" do
    render_markdown "[Hello](world 'title')"

    expect(page).to have_css "a", text: "Hello"
    expect(page).to have_css "a[title='title']"
    expect(page).to have_css "a[href='world']"
  end

  it "supports emphasis" do
    render_markdown "*Hello*"

    expect(page).to have_css "em", text: "Hello"
  end

  it "supports strong" do
    render_markdown "**Hello**"

    expect(page).to have_css "p strong", text: "Hello"
  end

  it "supports blockquotes" do
    render_markdown "> Hello"

    expect(page).to have_css "blockquote p", text: "Hello"
  end

  it "supports horizontal rules" do
    render_markdown "---"

    expect(page).to have_css "hr"
  end

  it "supports images" do
    render_markdown "![alt](src 'title')"

    expect(page).to have_css "img[alt='alt']"
    expect(page).to have_css "img[title='title']"
  end

  it "supports softbreaks in content as spaces" do
    render_markdown <<~MD
      One
      Two

      Three
    MD

    expect(page).to have_css "p", count: 2
    expect(page).to have_css "p", text: "One Two"
    expect(page).to have_css "p", text: "Three"
  end

  it "supports emphasis inside a table" do
    render_markdown <<~MD
      | Header           |
      | ------           |
      | *Italic*         |
      | ___emphasized___ |
    MD

    expect(page).to have_css "table"
    expect(page).to have_css "td > em", text: "Italic"
    expect(page).to have_css "td > em", text: "emphasized"
  end

  it "supports images inside a table" do
    render_markdown <<~MD
      |Image|
      |-----|
      |![Some image](/images/something.png)|
    MD

    expect(page).to have_css "table"
    expect(page).to have_css "td > img[alt='Some image'][src='/images/something.png']"
  end
end
