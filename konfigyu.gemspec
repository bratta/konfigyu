# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'konfigyu/version'

Gem::Specification.new do |spec|
  spec.name          = 'konfigyu'
  spec.version       = Konfigyu::VERSION
  spec.authors       = ['Tim Gourley']
  spec.email         = ['tgourley@gmail.com']

  spec.summary       = 'Easily manage YAML config files for your application.'
  spec.description   = 'Allows for customization of your YAML config file with basic requirements.'
  spec.homepage      = 'https://github.com/bratta/konfigyu'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Required dependencies
  spec.add_dependency 'syck', '~> 1.3.0'
  spec.add_dependency 'sycl', '~> 1.6'

  # Development Dependencies
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug', '~> 10.0.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.8.0'
  spec.add_development_dependency 'rubocop', '~> 0.59.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.29.1'
end
