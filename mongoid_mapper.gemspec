require_relative "lib/mongoid_mapper/version"

Gem::Specification.new { |spec|
  spec.name = "mongoid_mapper"
  spec.version = MongoidMapper::VERSION
  spec.authors = ["Wenoa Studio"]
  spec.email = ["desarrollo@wenoa.studio"]

  spec.summary = "DataMapper-style persistence layer over Mongoid with transaction-aware aggregations."
  spec.description = spec.summary
  spec.homepage = "https://github.com/wenoa/mongoid-mapper"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "mongoid", "~> 9.1"
}
