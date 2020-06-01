# frozen_string_literal: true

class AddSentAtFieldToBeneficiary < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiaries, :sent_at, :datetime, after: :pin
    Beneficiary.find_each do |record|
      record.update_column(:sent_at, record.created_at)
    end
  end
end
