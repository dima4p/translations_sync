# encoding: utf-8

class TranslatonsSync

  attr_accessor :translations, :list
  DEFAULT_LIST = 'ru,en'
  EXCLUDE_LIST = ''
  TAIL = '=TODO'

  def initialize(list = nil, exclude = nil)
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    @translations = I18n.backend.send :translations
    @full_list = ((list || DEFAULT_LIST).split(',').map(&:to_sym) + translations.keys).uniq
    exclude = (exclude || EXCLUDE_LIST).split(',').map(&:to_sym)
    @list = @full_list - exclude
    @flat = {}
    @list.each do |lang|
      flatten_keys(lang, translations[lang] || {}, @flat)
    end
    @flat.delete([:pluralize]) # we do not need this proc if it exists
    @pluralize_keys = @list.inject({}) do |acc, lang|
      acc[lang] = if locale_pluralize = I18n.backend.send(:lookup, lang, :pluralize) and
          locale_pluralize.respond_to?(:call)
        ((0..100).map do |n|
          locale_pluralize.call n
        end << :other).uniq
      else
        [:one, :other]
      end
      acc
    end
  end

  def locales_with_missing
    unless @locales_with_missing
      size = list.size
      @locales_with_missing = []
      @flat.each_pair do |key, val|
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
      @flat.each_pair do |key, val|
        (locales_with_missing - val.keys).each do |lang|
          push_to_hash @missing[lang], key, val, true
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
      @flat.each_pair do |key, val|
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
      @flat.each_pair do |key, val|
        lang = val.keys.first
        push_to_hash @singles[lang], key, val, false if val.size == 1
      end
      @singles.stringify_keys!
    end
    @singles
  end

  private

  def flatten_keys(lang, src, dest = {}, prefix = [])
    src.each_pair do |key, value|
      new = prefix.dup << key
      if value.is_a? Hash
        if value.keys.include? :other
          insert_translation(dest, new, lang, value)
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

  def push_to_hash(hash, keys, val, missing)
    key = keys.pop
    h = hash
    keys.each do |k|
      h[k.to_s] = {} unless h[k.to_s]
      h = h[k.to_s]
    end
    if missing
      lang = @full_list.detect do |lang|
        val[lang]
      end
      if val[lang].is_a? Hash
        h[key.to_s] = {}
        @pluralize_keys[lang].each do |pkey|
          h[key.to_s][pkey.to_s] = (val[lang][pkey] || val[lang][:other]) + TAIL
        end
      elsif val[lang].is_a? Array
        h[key.to_s] = val[lang].map do |text|
          text.is_a?(String) ? (text + TAIL) : text
        end
      else
        h[key.to_s] = val[lang].to_s + TAIL
      end
    else
      value = val.values.first
      value.stringify_keys! if value.is_a? Hash
      h[key.to_s] = value
    end
    keys.push key
  end

end
