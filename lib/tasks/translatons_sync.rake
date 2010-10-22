# encoding: utf-8
require 'ya2yaml'
namespace :translatons do

  PARAMS = '. LIST=locales,to,use EXCLUDE=locales,to,ignore'

  desc "Synchronizes the existing translations" + PARAMS
  task :sync => :environment do
    s = TranslatonsSync.new ENV['LIST'], ENV['EXCLUDE']
    s.missing.keys.each do |lang|
      filename = File.join Rails.root, 'config', 'locales', "missing_#{lang}.yml"
      print filename + ' ...  '
      File.open(filename, "w") do |file|
        file.write({lang.to_s => s.missing[lang]}.ya2yaml)
      end
      puts 'Done'
    end
  end

  desc "Detects the translations existing only in one locale" + PARAMS
  task :singles => :environment do
    s = TranslatonsSync.new ENV['LIST'], ENV['EXCLUDE']
    filename = File.join Rails.root, 'config', 'locales', "singles.yml"
    if s.singles.size > 0
      File.open(filename, "w") do |file|
        file.write(s.singles.ya2yaml)
      end
      puts filename + ' <= ' + s.singles.keys.join(', ')
    else
      puts 'No singels are found'
    end
  end

end
