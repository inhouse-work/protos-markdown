# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "protos-markdown"
  spec.version = "1.0.0"
  spec.authors = ["Nolan Tait"]
  spec.email = ["nolanjtait@gmail.com"]

  spec.summary = "A markdown renderer with Phlex and Protos"
  spec.description = "A markdown renderer with Phlex and Protos"
  spec.homepage = "https://github.com/inhouse-work/protos-markdown"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata["funding_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "commonmarker", "~> 2.3"
  spec.add_dependency "protos", "~> 1"
  spec.add_dependency "rouge", "~> 4"

  spec.metadata["rubygems_mfa_required"] = "true"
end
