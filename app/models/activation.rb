# == Schema Information
#
# Table name: tokens
#
#  id         :integer          not null, primary key
#  token      :string(255)
#  expire_at  :datetime
#  member_id  :integer
#  is_used    :boolean
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Activation < Token

  after_create :send_token

  def confirmed
    super
    member.active
  end
end
