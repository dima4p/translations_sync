require 'rdoc/task'
require 'rubygems'
require 'rubygems/package_task'
# require 'spec/rake/spectask'
require 'rubygems/specification'
require 'date'

GEM = "translations_sync"
GEM_VERSION = "0.4.14"
AUTHOR = "Dmitri Koulikoff"
EMAIL = "koulikoff@gmail.com"
HOMEPAGE = "http://github.com/dima4p/translations_sync/"
SUMMARY = "Synchronizes the different locales represeinted in yaml for I18n"

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = GEM
  gem.version = GEM_VERSION
  gem.homepage = HOMEPAGE
  gem.license = "MIT"
  gem.summary = SUMMARY
  gem.description = SUMMARY
  gem.email = EMAIL
  gem.authors = ["Dmitri Koulikoff"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

desc 'Generate documentation for the translations_sync plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TranslationsSync'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
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
task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspec_rails_scaffold_templates #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
