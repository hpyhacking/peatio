# encoding: UTF-8
# frozen_string_literal: true

class Trigger < ApplicationRecord
  extend Enumerize

  belongs_to :order, required: true

  # Enumerized list of statuses supported by trigger
  #
  # @note
  #   pending(initial,default)
  #   Trigger and order were created and persisted in DB.
  #
  #   active
  #   Trigger was added to triggerbook and waiting for being triggered by trade.
  #
  #   done
  #   Trigger was triggered by trade and thrown appropriate order.
  #
  #   cancelled
  #   Trigger was created but order was rejected by system on creation or
  #   trigger was activated but order was cancelled by user.
  #
  #              (1)              (2)
  #   Pending --------> Active ----------> Done
  #      |                |
  #      |(3)             |(4)
  #      |                |
  #      '------------> Cancelled
  #
  # 1 - add to triggerbook and lock order funds
  # 2 - triggered by trade
  # 3 - reject order on submit
  # 4 - cancel order by user
  STATES = { pending: 0, active: 100, done: 200, cancelled: 255 }.freeze

  # TODO: Order types documentation.
  TYPES = {
    # Regular order types:
    market:              10,
    limit:               11,
    stop_loss:           20,
    stop_loss_limit:     21,
    trailing_stop:       30,
    trailing_stop_limit: 31,
    oco:                 41,

    # Margin order types:
    margin_market:              110,
    margin_limit:               111,
    margin_stop_loss:           120,
    margin_stop_loss_limit:     121,
    margin_trailing_stop:       130,
    margin_trailing_stop_limit: 131,
    margin_oco:                 141
  }.freeze

  enumerize :state, in: STATES, scope: true

  enumerize :order_type, in: TYPES, scope: true
end

# == Schema Information
# Schema version: 20201125134745
#
# Table name: triggers
#
#  id         :bigint           not null, primary key
#  order_id   :bigint           not null
#  order_type :integer          unsigned, not null
#  value      :binary(128)      not null
#  state      :integer          default("pending"), unsigned, not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_triggers_on_order_id    (order_id)
#  index_triggers_on_order_type  (order_type)
#  index_triggers_on_state       (state)
#
