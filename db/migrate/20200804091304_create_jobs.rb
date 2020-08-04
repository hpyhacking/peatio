# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :name, null: false
      t.integer :pointer, unsigned: true
      t.integer :counter
      t.json :data
      t.integer :error_code, limit: 1, unsigned: true, default: 255, null: false
      t.string :error_message
      t.datetime 'started_at'
      t.datetime 'finished_at'
    end
  end
end
