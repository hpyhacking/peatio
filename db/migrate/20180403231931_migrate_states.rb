# encoding: UTF-8
# frozen_string_literal: true

class MigrateStates < ActiveRecord::Migration
  def change
    execute %{UPDATE deposits SET aasm_state = 'submitted' WHERE aasm_state = 'submitting'}
    execute %{UPDATE deposits SET aasm_state = 'accepted' WHERE aasm_state = 'checked' OR aasm_state = 'warning'}
    execute %{UPDATE deposits SET aasm_state = 'canceled' WHERE aasm_state = 'cancelled'}
    execute %{UPDATE withdraws SET aasm_state = 'prepared' WHERE aasm_state = 'submitting'}
    execute %{UPDATE withdraws SET aasm_state = 'suspected' WHERE aasm_state = 'suspect'}
    execute %{UPDATE withdraws SET aasm_state = 'succeed' WHERE aasm_state = 'done'}
    execute %{UPDATE withdraws SET aasm_state = 'canceled' WHERE aasm_state = 'cancelled'}
  end
end
