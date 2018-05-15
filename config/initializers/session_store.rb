# encoding: UTF-8
# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_store,
                                       key:          '_peatio_session',
                                       expire_after: ENV.fetch('SESSION_LIFETIME').to_i
