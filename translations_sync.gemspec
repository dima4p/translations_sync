# -*- encoding: utf-8 -*-
# stub: translations_sync 0.4.6 ruby lib

Gem::Specification.new do |s|
  s.name = "translations_sync"
  s.version = "0.4.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Dmitri Koulikoff"]
  s.date = "2016-06-17"
  s.description = "Synchronizes the different locales represeinted in yaml for I18n"
  s.email = "koulikoff@gmail.com"
  s.executables = ["translations_sync"]
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.files = ["Changelog", "MIT-LICENSE", "README", "Rakefile", "bin/translations_sync", "init.rb", "lib/tasks", "lib/tasks/translations_sync.rake", "lib/translations_sync.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/dima4p/translations_sync/"
  s.rubygems_version = "2.5.1"
  s.summary = "Synchronizes the different locales translations represeinted in yaml for I18n"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency 'activesupport'
      s.add_runtime_dependency 'ya2yaml'
    else
      s.add_dependency 'activesupport'
      s.add_dependency 'ya2yaml'
    end
  else
    s.add_dependency 'activesupport'
    s.add_dependency 'ya2yaml'
  end
end
