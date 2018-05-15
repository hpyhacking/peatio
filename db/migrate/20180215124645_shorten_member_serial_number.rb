# encoding: UTF-8
# frozen_string_literal: true

class ShortenMemberSerialNumber < ActiveRecord::Migration
  def change
    if defined?(Member)
      Member.find_each do |member|
        if member.sn.length > 12
          member.sn = nil
          member.send(:assign_sn)
          member.save!
        end
      end
    end
    change_column :members, :sn, :string, null: false, limit: 12, index: true
  end
end
