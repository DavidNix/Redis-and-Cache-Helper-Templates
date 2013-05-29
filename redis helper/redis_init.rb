# Put this file in config/initializers
puts RedisHelper.redis_url

RedisHelper.init_connection_pool

Resque.redis = RedisHelper.redis_url