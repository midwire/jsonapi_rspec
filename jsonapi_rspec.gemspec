# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonapi_rspec/version'

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi_rspec'
  spec.version       = JsonapiRspec::VERSION
  spec.authors       = ['Chris Blackburn']
  spec.email         = ['bogus@example.com']

  spec.summary       = 'Provides RSpec matchers for json:api related specs'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/midwire/jsonapi_rspec'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new(">= #{Bundler.root.join('.ruby-version').read.strip}")
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'midwire_common'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'activesupport', '>= 4.2.8'
end
