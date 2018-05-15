# encoding: UTF-8
# frozen_string_literal: true

module SessionUtils
  def memoize_member_session_id(member_id, session_id, options = {})
    options[:expire_after] ||= ENV.fetch('SESSION_LIFETIME').to_i
    Rails.cache.write("peatio:sessions:#{member_id}:#{session_id}", 1, options)
  end

  def fetch_member_session_ids(member_id)
    redis = Rails.cache.instance_variable_get(:@data)
    redis.keys("peatio:sessions:#{member_id}:*")
         .map { |k| k.split(':').last }
  end

  def destroy_member_sessions(member_id)
    redis = Rails.cache.instance_variable_get(:@data)
    redis.keys("peatio:sessions:#{member_id}:*")
         .map { |k| [k, k.split(':').last] }
         .flatten
         .tap { |keys| redis.del(*keys) }
  end
end
