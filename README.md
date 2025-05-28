# Protos Markdown

Markdown component built with [Protos](https://github.com/inhouse-work/protos).

This is a fork of [phlex-markdown](https://github.com/phlex-ruby/phlex-markdown).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add protos-markdown

If bundler is not being used to manage dependencies, install the gem by
executing:

    $ gem install protos-markdown

## Usage

This library lets you define your own component and override elements, including
using the standard protos conventions:

```ruby
class Markdown < Protos::Markdown
  def h1(**) = super(class: css[:title], **)
  def ul(**) = super(class: "ml-4 pt-2", **)

  private

  def theme
    {
      title: "font-bold text-xl"
    }
  end
end
```

Rendering the component outputs our custom css:

```ruby
content = <<~MD
  # Hello World

  - A
  - B
  - C
MD

output = Markdown.new(content).call
```

Which outputs the following html:

```html
<h1 class="font-bold text-xl" id="hello-world">Hello World</h1>
<ul class="ml-4 pt-2">
  <li>A</li>
  <li>B</li>
  <li>C</li>
</ul>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/inhouse-work/protos-markdown.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
