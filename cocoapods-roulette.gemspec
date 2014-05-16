# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_roulette.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-roulette"
  spec.version       = CocoapodsRoulette::VERSION
  spec.authors       = ["Heiko Behrens", "Marcel Jackwerth"]
  spec.email         = ["mail@heikobehrens.net", "marceljackwerth@gmail.com"]
  spec.summary       = %{Builds an empty project with three random gems.}
  spec.description   = %q{A CocoaPods plugin which gives you a combination of three random pods to build your app with.}
  spec.homepage      = "http://sirlantis.github.io/cocoapods-roulette/"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] + Dir["bin/*"] + %w{ LICENSE }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
