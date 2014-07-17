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

class ResetPassword < Token
  attr_accessor :email
  attr_accessor :password

  validates :password, presence: true, on: :update, length: { minimum: 6, maximum: 64 }

  after_create :send_token
  after_update :reset_password

  private

  def reset_password
    self.member.identity.update_attributes \
      password: self.password,
      password_confirmation: self.password
  end
end
