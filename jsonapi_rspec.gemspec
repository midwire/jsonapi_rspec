
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonapi_rspec/version'

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi_rspec'
  spec.version       = JsonapiRspec::VERSION
  spec.authors       = ['Chris Blackburn']
  spec.email         = ['chris@midwiretech.com']

  spec.summary       = 'Provides RSpec matchers for json:api related specs'
  spec.description   = spec.summary
  spec.homepage      = 'TODO: Put your gem\'s website or public repo URL here.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15.4'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-nav', '~> 0.2.4'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'midwire_common', '~> 0.1'

  spec.add_dependency 'activesupport', '>= 4.2.8'
end
