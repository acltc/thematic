# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thematic/version'

Gem::Specification.new do |spec|
  spec.name          = "thematic"
  spec.version       = Thematic::VERSION
  spec.authors       = ["Jay Wengrow"]
  spec.email         = ["jaywngrw@gmail.com"]
  spec.summary       = %q{An automated way that prepares HTML/CSS/JS themes for Rails projects.}
  spec.description   = %q{By running simple commands from the terminal, you can automatically convert regular HTML/CSS/JS themes and have them integrate into your Rails app so that it plays nicely with the asset pipeline.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
