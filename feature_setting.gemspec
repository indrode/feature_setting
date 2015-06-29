# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feature_setting/version'

Gem::Specification.new do |spec|
  spec.name          = 'feature_setting'
  spec.version       = FeatureSetting::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['Indro De']
  spec.email         = ['indro.de@gmail.com']

  spec.summary       = 'A lightweight feature/setting DSL for Rails applications.'
  spec.description   = 'This gem introduces the concept of "features" and "settings" to your Rails app. It provides an easy way to define such features and settings with default values right in your code and will persist them in the database.'
  spec.homepage      = 'https://github.com/indrode/feature_setting'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '~> 4.0'
  spec.add_runtime_dependency 'activerecord', '~> 4.0'
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'byebug', '~> 0'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0'
end
