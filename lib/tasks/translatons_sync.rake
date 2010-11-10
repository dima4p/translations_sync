# encoding: utf-8
namespace :translatons do

  PARAMS = '. LIST=locales,to,use EXCLUDE=locales,to,ignore'

  desc "Synchronizes the existing translations" + PARAMS +  ' NAME=file_name_prefix'
  task :sync => :environment do
    ts = TranslatonsSync.new ENV['LIST'], ENV['EXCLUDE']
    name = ENV['NAME'] || 'missing'
    ts.missing.keys.sort.each do |lang|
      filename = File.join Rails.root, 'config', 'locales', "#{name}_#{lang}.yml"
      print filename + ' ...  '
      File.open(filename, "a") do |file|
        file.write(TranslatonsSync.to_yaml({lang => ts.missing[lang]}))
      end
      puts 'Done'
    end
    puts "All is synchronized" if ts.missing.size == 0
  end

  desc "Detects the translations existing only in one locale" + PARAMS
  task :singles => :environment do
    ts = TranslatonsSync.new ENV['LIST'], ENV['EXCLUDE']
    filename = File.join Rails.root, 'config', 'locales', "singles.yml"
    if ts.singles.size > 0
      File.open(filename, "w") do |file|
        file.write(TranslatonsSync.to_yaml ts.singles)
      end
      puts filename + ' <= ' + ts.singles.keys.join(', ')
    else
      puts 'No singels are found'
    end
  end

end
