# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'feature_setting/version'

Gem::Specification.new do |spec|
  spec.name          = 'feature_setting'
  spec.version       = FeatureSetting::VERSION
  spec.authors       = ['Indro De']
  spec.email         = ['indro.de@gmail.com']

  spec.summary       = 'A lightweight feature/setting DSL for Rails applications.'
  spec.description   = %q{This gem introduces the concept of "features" and "settings" to your Rails app. It provides an easy way to define such features and settings with default values right in your code and will persist them in the database.}
  spec.homepage      = 'https://github.com/indrode/feature_setting'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '~> 4.0'
  spec.add_runtime_dependency 'activerecord', '~> 4.0'
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
