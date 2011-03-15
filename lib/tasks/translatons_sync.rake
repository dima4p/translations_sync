# encoding: utf-8
namespace :translatons do

  PARAMS = '. LIST=locales,to,use EXCLUDE=locales,to,ignore'

  desc "Synchronizes the existing translations" + PARAMS +  ' NAME=file_name_prefix'
  task :sync => :environment do
    source = ENV['SOURCE'] || ENV['IN']
    ts = TranslatonsSync.new ENV['LIST'], ENV['EXCLUDE'], source
    name = ENV['NAME'] || ENV['IN'] || 'missing'
    ts.missing.keys.sort.each do |lang|
      filename = File.join Rails.root, 'config', 'locales', "#{name}_#{lang}.yml"
      print filename + ' ...  '
      if File.exist? filename
        hash = YAML::load(File.open(filename))
        File.open(filename, "w") do |file|
          file.write(TranslatonsSync.to_yaml(hash.deep_merge!(ts.missing.slice(lang))))
        end
        puts 'updated'
      else
        File.open(filename, "w") do |file|
          file.write(TranslatonsSync.to_yaml(ts.missing.slice lang))
        end
        puts 'created'
      end
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
      puts 'No singles were found'
    end
  end

  desc "Moves the key in the translations" + PARAMS + " KEY=key.to.move TO=where.to.move IN=filespec"
  task :move => :environment do
    source = ENV['SOURCE'] || ENV['IN']
    name = ENV['NAME'] || ENV['IN'] || 'moved'
    key = ENV['KEY'] or raise "Parameter KEY must be given"
    ts = TranslatonsSync.new ENV['LIST'], ENV['EXCLUDE'], source
    if ts.move key, ENV['TO']
      ts.moved.keys.sort.each do |lang|
        filename = File.join Rails.root, 'config', 'locales', "#{name}_#{lang}.yml"
        print filename + ' ...  '
        if File.exist? filename
          status = 'updated'
        else
          status = 'created'
        end
        File.open(filename, "w") do |file|
          file.write(TranslatonsSync.to_yaml(ts.moved.slice lang))
        end
        puts status
      end
    else
      puts "The key \"#{key}\" was not found"
    end
  end

end
