class Token::Activation < ::Token
  after_create :send_token

  def confirm!
    super
    member.active_email!
  end

  private

  def send_token
    TokenMailer.activation(member.email, token).deliver
  end
end
