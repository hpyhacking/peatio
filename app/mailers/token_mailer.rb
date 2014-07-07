class TokenMailer < ActionMailer::Base
  include AMQPQueue::Mailer

  default from: ENV['SYSTEM_MAIL_FROM']

  def reset_password(email, token)
    @token_url = edit_reset_password_url(token)
    mail :to => email
  end

  def reset_two_factor(email, token)
    @token_url = edit_reset_two_factor_url(token)
    mail :to => email
  end

  def activation(email, token)
    @token_url = edit_activation_url token
    mail :to => email
  end
end
