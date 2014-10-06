class Token::Activation < ::Token
  after_create :send_token

  def confirmed
    super
    member.active
  end
end
