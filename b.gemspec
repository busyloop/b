# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'b/version'

Gem::Specification.new do |gem|
  gem.name          = "b"
  gem.version       = B::VERSION
  gem.authors       = ["Moe"]
  gem.email         = ["moe@busyloop.net"]
  gem.description   = %q{A small, convenient benchmark-library.}
  gem.summary       = %q{A small, convenient benchmark-library.}
  gem.homepage      = "https://github.com/busyloop/b"
  gem.has_rdoc      = false

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'stdiotrap'
  gem.add_dependency 'hitimes'
  gem.add_dependency 'blockenspiel'
end
