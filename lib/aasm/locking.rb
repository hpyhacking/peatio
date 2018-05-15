# encoding: UTF-8
# frozen_string_literal: true

module AASM::Locking
  def aasm_write_state(*)
    lock!
    super
  end
end
