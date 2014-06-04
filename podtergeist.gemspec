# coding: utf-8
require File.expand_path('../lib/podtergeist/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'podtergeist'
  spec.version       = Podtergeist::VERSION
  spec.authors       = ['Robert Coleman']
  spec.email         = ['github@robert.net.nz']
  spec.description   = %q{CLI to create or append to podcast-compatible rss via args}
  spec.summary       = %q{CLI to create or append to podcast-compatible rss via args}
  spec.homepage      = 'https://github.com/rjocoleman/podtergeist'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0.18'
  spec.add_dependency 'taglib-ruby', '~> 0.6'
  spec.add_dependency 'mime-types', '~> 1.23'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'
end
