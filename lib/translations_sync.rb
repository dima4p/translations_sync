# encoding: utf-8
require 'ya2yaml'
require 'i18n'
require 'active_support/hash_with_indifferent_access'

class Hash
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end
end

if defined?(Rails)
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/translations_sync.rake'
    end
  end
end

class TranslationsSync

  attr_accessor :translations, :list
  attr_reader :flat
  EXCLUDE_LIST = ''
  TAIL = '=TODO'
  PKORDER = {'zero' => 0, 'one' => 1, 'two' => 2, 'few' => 3, 'many' => 5, 'other' => 9}
  PKLIST = PKORDER.keys
  RE = Regexp.new ' \d(' + PKORDER.keys.join('|') + '):'

  class << self
    def to_yaml(hash)
      translate_keys(hash).ya2yaml.gsub(RE, ' \1:')
    end

    private

    def translate_keys(hash)
      hash.each_pair do |key, v|
        if v.is_a? Hash
          if v.keys.sort == (v.keys & PKLIST).sort
            new = {}
            v.keys.each do |k|
              new["#{PKORDER[k]}#{k.to_s}"] = v[k]
            end
            hash[key] = new
          else
            translate_keys v
          end
        end
      end
      hash
    end
  end   # class << self

  def initialize(*args)
    params = args.pop if args.last.is_a? Hash
    params = (params || {}).with_indifferent_access
    unless args.size == 0
      list, exclude, source = agrs
      puts 'Deprecation warning: a Hash should be used to pass paramteters'
    end
    list ||= params[:list]
    exclude ||= params[:exclude]
    source ||= params[:source]
    ignore = params[:ignore]
    @full_list = list ? list.split(',').map(&:to_sym) : I18n.available_locales
    @full_list = @full_list.uniq
    exclude = (exclude || EXCLUDE_LIST).split(',').map(&:to_sym)
    @list = @full_list - exclude
    rules_key = %w[i18n.plural.rule pluralize].detect do |rule|
      @list.detect do |lang|
        locale_pluralize = I18n.backend.send(:lookup, lang, rule) and
          locale_pluralize.respond_to?(:call)
      end
    end
    @pluralize_keys = @list.inject({}) do |acc, lang|
      acc[lang] = if rules_key and
          locale_pluralize = I18n.backend.send(:lookup, lang, rules_key) and
          locale_pluralize.respond_to?(:call)
        ((0..100).map do |n|
          locale_pluralize.call n
        end << :other).uniq
      else
        [:one, :other]
      end
      acc
    end

    translations_path_re = Regexp.new "#{translations_dir}(\\/[a-z]{2}(?:-[A-Z]{2})?)?\\/[-_/0-9a-zA-Z]+(?:(_|.)[a-z]{2}(?:-[A-Z]{2})?)?\\.(?:yml|rb)\\Z"
    I18n.load_path.find do  |path|
      path.match translations_path_re
    end
    @prefix = $1 or @separator = $2

    if source
      translations_path_re = Regexp.new "#{translations_dir}(\\/[a-z]{2}(?:-[A-Z]{2})?)?\\/#{Regexp.escape source}(?:(_|.)[a-z]{2}(?:-[A-Z]{2})?)?\\.(?:yml|rb)\\Z"
      I18n.load_path.reject! do |path|
        path !~ translations_path_re
      end
    end

    if ignore
      translations_path_re = Regexp.new "#{translations_dir}#{'\\/[^/]+' if @prefix}\\/#{Regexp.escape ignore}"
      I18n.load_path.reject! do |path|
        path =~ translations_path_re
      end
    end

    I18n.reload!
    I18n.backend.send(:init_translations)
    translations = I18n.backend.send :translations
    @flat = {}
    @list.each do |lang|
      flatten_keys(lang, translations[lang] || {}, @flat)
    end
    @flat.delete(rules_key.split('.').map(&:to_sym)) if rules_key # we do not need this proc if it exists
    transliterate = [:i18n, :transliterate]
    @flat.keys.select do |key|
      @flat.delete(key) if key[0..1] == transliterate
    end
  end   # initialize

  def locales_with_missing
    unless @locales_with_missing
      size = list.size
      @locales_with_missing = []
      flat.each_pair do |key, val|
        if val.size < size
          (@locales_with_missing += list - val.keys).uniq!
          break if @locales_with_missing.size == size
        end
      end
    end
    @locales_with_missing
  end

  def missing
    unless @missing
      @missing = {}
      locales_with_missing.each do |lang|
        @missing[lang] = {}
      end
      flat.each_pair do |key, val|
        (locales_with_missing - val.keys).each do |lang|
          push_to_hash @missing[lang], lang, key, val, :missing
        end
      end
      @missing.stringify_keys!
    end
    @missing
  end

  def locales_with_singles
    unless @locales_with_singles
      size = list.size
      @locales_with_singles = []
      flat.each_pair do |key, val|
        if val.size < size
          (@locales_with_singles += val.keys).uniq! if val.size == 1
          break if @locales_with_singles.size == size
        end
      end
    end
    @locales_with_singles
  end

  def singles
    unless @singles
      @singles = {}
      locales_with_singles.each do |lang|
        @singles[lang] = {}
      end
      flat.each_pair do |key, val|
        lang = val.keys.first
        push_to_hash @singles[lang], lang, key, val, :singles if val.size == 1
      end
      @singles.stringify_keys!
    end
    @singles
  end

  def move(key, destination)
    key = key.split('.').map(&:to_sym)
    key_length = key.length
    return false if key_length < 1
    destination ||= ''
    destination = destination.split('.').map(&:to_sym)
    destination << key.last if destination.size == 0
    puts "key=#{key.inspect} destination=#{destination.inspect}"
    result = false
    flat.each_pair do |array, val|
      if array[0, key_length] == key
        array[0, key_length] = destination
        puts array.inspect
        result = true
      end
    end
    @moved = nil
    puts result
    result
  end

  def moved
    unless @moved
      @moved = {}
      @list.each do |lang|
        @moved[lang] = {}
      end
      flat.each_pair do |key, val|
        puts key.inspect
        val.keys.each do |lang|
          push_to_hash @moved[lang], lang, key, val, :moved
        end
      end
      @moved.keys.each do |key|
        @moved.delete(key) if @moved[key].size == 0
      end
      @moved.stringify_keys!
    end
    @moved
  end

  def remove(key)
    key = key.split('.').map(&:to_sym)
    key_length = key.length
    result = false
    flat.reject! do |array, val|
      r = array[0, key_length] == key
      result ||= r
      r
    end
    @moved = nil
    result
  end

  def filename_for(name, lang = nil)
    if lang
      if @prefix
        "#{translations_dir}/#{lang}/#{name}.yml"
      else
        "#{translations_dir}/#{name}#{@separator}#{lang}.yml"
      end
    else
      "#{translations_dir}/#{name}.yml"
    end
  end

  private

  def flatten_keys(lang, src, dest = {}, prefix = [])
    src.each_pair do |key, value|
      new = prefix.dup << key
      if value.is_a? Hash
        if (value.keys & [:one, :other]).size > 0
          insert_translation(dest, new, lang, value)
        # we do not process gem faker
        elsif prefix == [] and key.to_sym == :faker
        else
          flatten_keys lang, value, dest, new
        end
      else
        insert_translation(dest, new, lang, value)
      end
    end
    dest
  end

  def insert_translation(dest, key, lang, value)
    dest[key] ||= {}
    dest[key][lang] = value
  end

  def push_to_hash(hash, target, keys, val, mode)
    key = keys.pop
    h = hash
    keys.each do |k|
      h[k.to_s] = {} unless h[k.to_s]
      h = h[k.to_s]
    end
    case mode
    when :missing
      lang = @full_list.detect do |lang|
        not val[lang].nil?
      end
      if val[lang].is_a? Hash
        h[key.to_s] = {}
        @pluralize_keys[target].each do |pkey|
          h[key.to_s][pkey.to_s] =
            (val[lang][pkey] || val[lang][:many] || val[lang][:other]) + TAIL
        end
      elsif val[lang].is_a? Array
        h[key.to_s] = val[lang].map do |text|
          text.is_a?(String) ? (text + TAIL) : text
        end
      else
        begin
          h[key.to_s] = val[lang].to_s + TAIL
        rescue
          puts %Q(Can not assign to the key "#{keys.inspect}" value "#{val[lang]} for language #{target}")
          raise
        end
      end
    when :singles
      value = val.values.first
      value.stringify_keys! if value.is_a? Hash
      h[key.to_s] = value
    when :moved
      value = val[target]
      raise "The translations are not synchronized for #{keys.inspect}" if value.nil?
      value.stringify_keys! if value.is_a? Hash
      h[key.to_s] = value
    end
    keys.push key
  end

  def translations_dir
    @translations_dir ||=
        common_prefix(I18n.config.load_path.grep Regexp.new FileUtils.pwd)
  end

  def common_prefix(paths)
    return '' if paths.empty?
    return paths.first.split('/').slice(0...-1).join('/') if paths.length <= 1
    arr = paths.sort
    first = arr.first.split('/')
    last = arr.last.split('/')
    i = 0
    i += 1 while first[i] == last[i] && i <= first.length
    first.slice(0, i).join('/')
  end

end
