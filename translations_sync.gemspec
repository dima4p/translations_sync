# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "translations_sync"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dmitri Koulikoff"]
  s.date = "2012-09-16"
  s.description = "Synchronizes the different locales represeinted in yaml, in particular, for I18n"
  s.email = "koulikoff@gmail.com"
  s.executables = ["translations_sync"]
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.files = ["MIT-LICENSE", "README", "Rakefile", "Changelog", "init.rb", "bin/translations_sync", "lib/tasks", "lib/tasks/translations_sync.rake", "lib/translations_sync.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/dima4p/translations_sync/"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.19"
  s.summary = "Synchronizes the different locales represeinted in yaml, in particular, for I18n"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ya2yaml>, [">= 0"])
    else
      s.add_dependency(%q<ya2yaml>, [">= 0"])
    end
  else
    s.add_dependency(%q<ya2yaml>, [">= 0"])
  end
end
