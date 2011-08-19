require 'rake/rdoctask'
require 'rubygems'
require 'rake/gempackagetask'
# require 'spec/rake/spectask'
require 'rubygems/specification'
require 'date'

GEM = "translations_sync"
GEM_VERSION = "0.2.9"
AUTHOR = "Dmitri Koulikoff"
EMAIL = "koulikoff@gmail.com"
HOMEPAGE = "http://github.com/dima4p/translations_sync/"
SUMMARY = "Synchronizes the different locales represeinted in yaml, in particular, for I18n"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE

   s.add_dependency "ya2yaml"

  s.executables = 'translations_sync'
  s.default_executable = 'translations_sync'
  s.require_path = 'lib'
  s.files = %w(MIT-LICENSE README Rakefile Changelog init.rb) +
    Dir.glob("{bin,lib,spec}/**/*") -
    Dir.glob("{bin,lib,spec}/**/*~")
end

desc 'Generate documentation for the translations_sync plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TranslationsSync'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

# task :default => :spec
# desc "Default: Run specs"
# Spec::Rake::SpecTask.new do |t|
#   t.spec_files = FileList['spec/**/*_spec.rb']
#   t.spec_opts = %w(-fs --color)
# end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
