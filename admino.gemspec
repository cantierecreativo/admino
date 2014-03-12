# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'admino/version'

Gem::Specification.new do |spec|
  spec.name          = 'admino'
  spec.version       = Admino::VERSION
  spec.authors       = ['Stefano Verna']
  spec.email         = ['s.verna@cantierecreativo.net']
  spec.description   = %q{Make administrative views creation less repetitive}
  spec.summary       = %q{Make administrative views creation less repetitive}
  spec.homepage      = 'https://github.com/cantierecreativo/admino'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'showcase', '~> 0.2.4'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'activemodel'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'i18n'
  spec.add_development_dependency 'rspec-html-matchers'
  spec.add_development_dependency 'actionpack'
end

