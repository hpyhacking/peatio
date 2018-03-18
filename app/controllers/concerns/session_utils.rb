module SessionUtils
  def memoize_member_session_id(member_id, session_id)
    Rails.cache.write("peatio:sessions:#{member_id}:#{session_id}", 1, expire_after: ENV.fetch('SESSION_EXPIRE').to_i.minutes)
  end

  def destroy_member_sessions(member_id)
    redis = Rails.cache.instance_variable_get(:@data)
    redis.keys("peatio:sessions:#{member_id}:*")
         .map { |k| [k, k.split(':').last] }
         .flatten
         .tap { |keys| redis.del(*keys) }
  end
end
