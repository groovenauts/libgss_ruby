# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libgss/version'

Gem::Specification.new do |spec|
  spec.name          = "libgss"
  spec.version       = Libgss::VERSION
  spec.authors       = ["akima"]
  spec.email         = ["t-akima@groovenauts.jp"]
  spec.description   = %q{network library for Groovenauts GSS}
  spec.summary       = %q{network library for Groovenauts GSS}
  spec.homepage      = "http://www.groovenauts.jp/service/#gss"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "tengine_support"

  spec.add_runtime_dependency "httpclient"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "oauth"
end
