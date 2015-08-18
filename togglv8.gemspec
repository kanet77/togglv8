# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'togglv8/version'

Gem::Specification.new do |spec|
  spec.name          = "togglv8"
  spec.version       = Toggl::V8::VERSION
  spec.authors       = ["Tom Kane"]
  spec.email         = ["kexf7pqsdu@snkmail.com"]
  spec.summary       = %q{Toggl v8 API wrapper (See https://github.com/toggl/toggl_api_docs)}
  spec.homepage      = "https://github.com/kanet77/togglv8"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.requirements  << 'A Toggl account (https://toggl.com/)'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "awesome_print", "~> 1.6"
  spec.add_development_dependency "fivemat", "~> 1.3"
  spec.add_development_dependency "simplecov", "~> 0.10"

  spec.add_dependency "faraday", "~> 0.9"
  spec.add_dependency "oj", "~>2.12"
end
