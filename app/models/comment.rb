# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  content    :text
#  author_id  :integer
#  ticket_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Comment < ActiveRecord::Base
  acts_as_readable on: :created_at
  belongs_to :ticket
  belongs_to :author, class_name: 'Member', foreign_key: 'author_id'

  validates :content, presence: true
end
