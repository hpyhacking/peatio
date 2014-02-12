Peatio::Application.config.session_store :cookie_store,
  :key => '_peatio_session',
  :expire_after => ENV['SESSION_EXPIRE'].to_i.minutes

