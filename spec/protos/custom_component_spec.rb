# frozen_string_literal: true

require "protos/markdown"

RSpec.describe "Custom components" do
  before do
    stub_const(
      "CustomMarkdown", Class.new(Protos::Markdown) do
        def h1(**options) = super(class: css[:title], **options)
        def ul(**options) = super(class: "ml-4 pt-2", **options)

        private

        def theme
          {
            title: "font-bold text-xl"
          }
        end
      end
    )
  end

  it "supports custom components" do
    input = <<~MD
      # Hello World

      - A
      - B
      - C
    MD

    output = CustomMarkdown.new(input).call

    expected_output = <<~HTML
      <h1 class="font-bold text-xl" id="hello-world">Hello World</h1>
      <ul class="ml-4 pt-2">
        <li>A</li>
        <li>B</li>
        <li>C</li>
      </ul>
    HTML

    expect(output).to eq expected_output.gsub(/^\s+/, "").delete("\n")
  end
end
