# -*- encoding: utf-8 -*-
# stub: schema_plus_core 0.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "schema_plus_core"
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["ronen barzel"]
  s.date = "2015-10-18"
  s.description = "Provides an internal extension API to ActiveRecord, in the form of middleware-style callback stacks"
  s.email = ["ronen@barzel.org"]
  s.files = [".gitignore", ".travis.yml", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "gemfiles/Gemfile.base", "gemfiles/activerecord-4.2/Gemfile.base", "gemfiles/activerecord-4.2/Gemfile.mysql2", "gemfiles/activerecord-4.2/Gemfile.postgresql", "gemfiles/activerecord-4.2/Gemfile.sqlite3", "lib/schema_plus/core.rb", "lib/schema_plus/core/active_record/base.rb", "lib/schema_plus/core/active_record/connection_adapters/abstract_adapter.rb", "lib/schema_plus/core/active_record/connection_adapters/abstract_mysql_adapter.rb", "lib/schema_plus/core/active_record/connection_adapters/mysql2_adapter.rb", "lib/schema_plus/core/active_record/connection_adapters/postgresql_adapter.rb", "lib/schema_plus/core/active_record/connection_adapters/sqlite3_adapter.rb", "lib/schema_plus/core/active_record/connection_adapters/table_definition.rb", "lib/schema_plus/core/active_record/migration/command_recorder.rb", "lib/schema_plus/core/active_record/schema.rb", "lib/schema_plus/core/active_record/schema_dumper.rb", "lib/schema_plus/core/middleware.rb", "lib/schema_plus/core/schema_dump.rb", "lib/schema_plus/core/sql_struct.rb", "lib/schema_plus/core/version.rb", "schema_dev.yml", "schema_plus_core.gemspec", "spec/column_spec.rb", "spec/dumper_spec.rb", "spec/middleware_spec.rb", "spec/spec_helper.rb", "spec/sql_struct_spec.rb", "spec/support/enableable.rb", "spec/support/test_dumper.rb", "spec/support/test_reporter.rb"]
  s.homepage = "https://github.com/SchemaPlus/schema_plus_core"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Provides an internal extension API to ActiveRecord"
  s.test_files = ["spec/column_spec.rb", "spec/dumper_spec.rb", "spec/middleware_spec.rb", "spec/spec_helper.rb", "spec/sql_struct_spec.rb", "spec/support/enableable.rb", "spec/support/test_dumper.rb", "spec/support/test_reporter.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["~> 4.2"])
      s.add_runtime_dependency(%q<schema_monkey>, ["~> 2.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0.0"])
      s.add_development_dependency(%q<rspec-given>, [">= 0"])
      s.add_development_dependency(%q<schema_dev>, ["~> 3.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<simplecov-gem-profile>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, ["~> 4.2"])
      s.add_dependency(%q<schema_monkey>, ["~> 2.1"])
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, ["~> 3.0.0"])
      s.add_dependency(%q<rspec-given>, [">= 0"])
      s.add_dependency(%q<schema_dev>, ["~> 3.3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<simplecov-gem-profile>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["~> 4.2"])
    s.add_dependency(%q<schema_monkey>, ["~> 2.1"])
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, ["~> 3.0.0"])
    s.add_dependency(%q<rspec-given>, [">= 0"])
    s.add_dependency(%q<schema_dev>, ["~> 3.3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<simplecov-gem-profile>, [">= 0"])
  end
end
