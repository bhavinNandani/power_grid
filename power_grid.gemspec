require_relative 'lib/power_grid/version'

Gem::Specification.new do |spec|
  spec.name          = "power_grid"
  spec.version       = PowerGrid::VERSION
  spec.authors       = ["Bhavin Nandani"]
  spec.email         = ["nandanibhavin@gmail.com"]

  spec.summary       = "A powerful, server-side processed table component for Rails."
  spec.description   = "PowerGrid provides a view component based table with server-side sorting, filtering, and pagination."
  spec.homepage      = "https://github.com/bhavinNandani/power_grid"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bhavinNandani/power_grid"
  spec.metadata["changelog_uri"] = "https://github.com/bhavinNandani/power_grid/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) || f.end_with?('.gem') }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.1", "< 8.0"
  spec.add_dependency "view_component", ">= 2.0", "< 4.0"
  spec.add_dependency "turbo-rails", ">= 1.0", "< 3.0"
  spec.add_dependency "importmap-rails", ">= 1.0", "< 3.0"

  spec.add_development_dependency "sqlite3", ">= 1.6", "< 1.7"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "capybara", "~> 3.0"
end
