# frozen_string_literal: true

require_relative "lib/activerecord/dbsnapshot/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord-dbsnapshot"
  spec.version = Activerecord::Dbsnapshot::VERSION
  spec.authors = ["Ryan Mammina"]
  spec.email = ["ryan@avamia.com"]

  spec.summary = "Dump and Restore database snapshots."
  spec.homepage = "https://github.com/avamia/activerecord-dbsnapshot"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/avamia/activerecord-dbsnapshot"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  # spec.add_dependency "example-gem", "~> 1.0"
end
