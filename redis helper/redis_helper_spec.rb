# place in spec/lib
require "spec_helper"

describe "RedisHelper" do

  it "responds to redis commands" do
    RedisHelper.set("test-key", "test-data")
    expect(RedisHelper.get("test-key")).to eq "test-data"
  end

  it "has correct connection pool class" do
    expect(RedisHelper.connection_type).to eq ConnectionPool
  end

end