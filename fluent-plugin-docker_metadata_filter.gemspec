# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-docker_metadata_filter"
  gem.version       = "0.1.2"
  gem.authors       = ["Jimmi Dyson"]
  gem.email         = ["jimmidyson@gmail.com"]
  gem.description   = %q{Filter plugin to add Docker metadata}
  gem.summary       = %q{Filter plugin to add Docker metadata}
  gem.homepage      = "https://github.com/fabric8io/fluent-plugin-docker_metadata_filter"
  gem.license       = "ASL2"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.has_rdoc      = false

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "docker-api"
  gem.add_runtime_dependency "lru_redux"

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest", "~> 4.0"
  gem.add_development_dependency "test-unit", "~> 3.0.2"
  gem.add_development_dependency "test-unit-rr", "~> 1.0.3"
  gem.add_development_dependency "copyright-header"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "bump"
end
