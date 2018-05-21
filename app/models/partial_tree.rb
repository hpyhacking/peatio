# encoding: UTF-8
# frozen_string_literal: true

class PartialTree < ActiveRecord::Base
  include BelongsToAccount
  belongs_to :proof, required: true
  serialize :json, JSON
end

# == Schema Information
# Schema version: 20180215144645
#
# Table name: partial_trees
#
#  id         :integer          not null, primary key
#  proof_id   :integer          not null
#  account_id :integer          not null
#  json       :text(65535)      not null
#  created_at :datetime
#  updated_at :datetime
#  sum        :string(255)
#
