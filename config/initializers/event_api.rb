# encoding: UTF-8
# frozen_string_literal: true

# Specifications are available in docs/specs/event_api.md.

require 'active_support/concern'
require 'active_support/lazy_load_hooks'
require 'amqp/event_api'
ActiveSupport.on_load(:active_record) { ActiveRecord::Base.include EventAPI::ActiveRecord::Extension }