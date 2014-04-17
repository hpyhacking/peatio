class SmsToken < Token

  VERIFICATION_CODE_LENGTH = 6

  attr_accessor :phone_number
  attr_accessor :verify_code

  validates_uniqueness_of :token, scope: :member_id
  validates :phone_number, phone: { possible: true, allow_blank: true, types: [:mobile] }

  def generate_token
    begin
      self.token = VERIFICATION_CODE_LENGTH.times.map{ Random.rand(9) + 1 }.join
      self.expire_at = DateTime.now.since(60 * 30)
    end while SmsToken.where(member_id: member_id, token: token).any?
  end

end
