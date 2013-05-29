require 'active_support/concern'

module CacheHelper
  extend ActiveSupport::Concern

  included do
    attr_accessor :prevent_caching
    after_save :cache_thyself
    after_destroy :delete_from_cache
  end

  def cache_thyself(cache_related_models=true)
    return if prevent_caching?
    to_cache = self._we_cache_this.merge(type: class_type)
    RedisHelper.with_connection do |conn|
      conn.set(self.redis_cache_key, to_cache.to_json)
    end
    true
  end

  def _we_cache_this
    self.as_json
  end

  def redis_cache_key
    CacheHelper.cache_key_for(self)
  end

  def self.cache_key_for(arg, uid=nil)
    if arg.is_a?(Class)
      return nil if uid.nil?
      "#{arg.to_s.underscore}-#{uid}"
    else # instance of class
      "#{arg.class.to_s.underscore}-#{arg.id}"
    end
  end

  def delete_from_cache
    RedisHelper.del(self.redis_cache_key)
  end

  def cached_json
    RedisHelper.get(self.redis_cache_key)
  end

  def info_hash_via_cache
    CacheHelper.json_hash(self.class, self.id)
  end

  # Pull json out of redis w/o needing instance of the object
  # Fall back to db if can't find cached data
  def self.json_hash(klass, uid)
    return {} if klass.nil? || uid.nil?
    key = cache_key_for(klass, uid)
    json_string = RedisHelper.get(key)
    final_hash = {}
    if json_string.present?
      final_hash = JSON.parse(json_string)
    elsif klass.ancestors.include?(ActiveRecord::Base)
      final_hash = klass.find(uid)._we_cache_this
    end
    indifferent_hash(final_hash)
  end

  private

  def self.indifferent_hash(hash)
    HashWithIndifferentAccess.new.merge(hash)
  end

  def prevent_caching?
    if self.prevent_caching
      self.prevent_caching = false
      return true
    end
    false
  end

end