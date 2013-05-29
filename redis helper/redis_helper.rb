class RedisHelper

  def self.redis_url
    ENV["YOUR_REDIS_URL"] # change this per your environment
  end

  def self.init_connection_pool
    uri = redis_url.present? ? URI.parse(redis_url) : nil

    @redis_pool ||= ConnectionPool.new(:size => 5, :timeout => 3) {
      if uri.nil?
        Redis.new
      else
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      end
    }
  end

  def self.with_connection(&block)
    if Rails.env.development? # useful if you have limited connections to redis
      begin
        @redis_pool.with(&block)
      rescue Redis::CommandError => e
        puts "Redis Error Rescued.  Error message:  #{e}."
      end
    else
      @redis_pool.with(&block)
    end
  end

  def self.connection_type
    @redis_pool.class
  end

  private
  def self.method_missing(name, *args, &block)
    RedisHelper.with_connection { |r| r.send(name, *args, &block) }
  end

end