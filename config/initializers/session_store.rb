# Be sure to restart your server when you modify this file.

Rails.application.config.session_store(
  :redis_store,
  key: '_peatio_session',
  expire_after: ENV['SESSION_EXPIRE'].to_i.minutes
)
