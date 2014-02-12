class Notice
  def self.get
    redis = Redis.new
    redis.get "title"
  end

  def self.set(content)
    redis = Redis.new
    redis.set "title", content
  end
end