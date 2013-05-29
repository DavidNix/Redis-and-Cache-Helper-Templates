# Redis and Cache Helper Templates for Rails

## Redis Helper
A service object that functions as a main point of interacting with Redis.

### Advantages
* Does not use a global variable for interaction with redis.
* Uses a connection pool to cache connections.

### Setup
1. Add this to your gemfile and run bundle install:

    gem 'json'
    gem 'hiredis'
    gem 'redis', '~> 3.0.1', :require => ["redis/connection/hiredis", "redis"]
    gem 'connection_pool', '~> 1.0.0'

2. Edit environment variable in redis_helper.rb to point to your correct redis url.
3. Add redis_init.rb to your config/initializers.
4. I suggest adding redis_helper.rb to app/services.  If not, you need to require it in application.rb, on a class by class basis, or in any folder that gets autoloaded.

To test on local environments, I suggest using homebrew to install redis locally.

### Usage
Use the block syntax:

    RedisHelper.with_connection do |connection|
        connection.get("some_key")
    end

Or use the simpler syntax:

    RedisHelper.get("some_key")

## Cache Helper
A concern for caching ActiveRecord obect json to Redis.

### Advantages
* Automatic fallback to the database if it can't find data in Redis.
* Use symbols or strings as keys to query the hash object returned by CacheHelper.
* Class methods to query Redis without ever needing to intantiate an object from the db.

### Setup
1.  Complete Redis Helper setup described above.
2.  I suggest adding cache_helper.rb to app/concerns.  If not, you need to require it in application.rb, on a class by class basis, or in any folder that gets autoloaded.
3.  Include the module like so:
    class Model < ActiveRecord::Base
    	include CacheHelper
4.  You're good to go!

### Usage
Before saving, use `self.prevent_caching = true` for a 1-time prevention of caching of the object.

Override `_we_cache_this` in the model's implementation to control extactly what you want cached.

If you have an instance of the model object already:

    user.info_hash_via_cache # => hash of the json data stored in redis
    user.info_hash_via_cache[:id] # => "3"
    user.info_hash_via_cache['id'] # => "3", strings work too!

If you have the class and id:
	
    json = CacheHelper.json_hash(User, 3)
    json[:id] # => "3"

## TO DOs
* Better namespacing of redis cache keys.



