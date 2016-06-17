# encoding: utf-8
namespace :translations do

  PARAMS = '. LIST=locales,to,use EXCLUDE=locales,to,ignore'

  def get_ts(skip_source = false)
    source = skip_source ? nil : ENV['SOURCE'] || ENV['IN']
    params = {}
    params[:list] = ENV['LIST'] if ENV['LIST']
    params[:exclude] = ENV['EXCLUDE'] if ENV['EXCLUDE']
    params[:source] = ENV['SOURCE'] || ENV['IN'] unless skip_source
    TranslationsSync.new params
  end

  def save_moved_files(ts, default_name)
    translations = ts.moved
    name = ENV['NAME'] || ENV['IN'] || default_name
    translations.keys.sort.each do |lang|
      filename = ts.filename_for name, lang
      print filename + ' ...  '
      if File.exist? filename
        status = 'updated'
      else
        status = 'created'
      end
      File.open(filename, "w") do |file|
        file.write(TranslationsSync.to_yaml(translations.slice lang))
      end
      puts status
    end
  end

  desc "Synchronizes the existing translations" + PARAMS +  ' NAME=file_name_prefix'
  task :sync => :environment do
    ts = get_ts
    name = ENV['NAME'] || ENV['IN'] || 'missing'
    ts.missing.keys.sort.each do |lang|
      filename = ts.filename_for name, lang
      print filename + ' ...  '
      if File.exist? filename
        hash = YAML::load(File.open(filename))
        File.open(filename, "w") do |file|
          file.write(TranslationsSync.to_yaml(hash.deep_merge!(ts.missing.slice(lang))))
        end
        puts 'updated'
      else
        File.open(filename, "w") do |file|
          file.write(TranslationsSync.to_yaml(ts.missing.slice lang))
        end
        puts 'created'
      end
    end
    puts "All is synchronized" if ts.missing.size == 0
  end

  desc "Detects the translations existing only in one locale" + PARAMS
  task :singles => :environment do
    ts = get_ts false
    filename = ts.filename_for 'singles', nil
    if ts.singles.size > 0
      File.open(filename, "w") do |file|
        file.write(TranslationsSync.to_yaml ts.singles)
      end
      puts filename + ' <= ' + ts.singles.keys.join(', ')
    else
      puts 'No singles were found'
    end
  end

  desc "Moves the key in the translations" + PARAMS + " KEY=key.to.move TO=where.to.move IN=filespec"
  task :move => :environment do
    key = ENV['KEY'] or raise "Parameter KEY must be given"
    ts = get_ts
    if ts.move key, ENV['TO']
      save_moved_files ts, 'moved'
    else
      puts "The key \"#{key}\" was not found"
    end
  end

  desc "Removes the key from the translations" + PARAMS + " KEY=key.to.move IN=filespec"
  task :remove => :environment do
    key = ENV['KEY'] or raise "Parameter KEY must be given"
    ts = get_ts
    if ts.remove key
      save_moved_files ts, 'removed'
    else
      puts "The key \"#{key}\" was not found"
    end
  end

end
