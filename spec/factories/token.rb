FactoryGirl.define do
  factory :token do
    member
  end

  factory :token_activation,     class: Token::Activation,    parent: :token
  factory :token_reset_password, class: Token::ResetPassword, parent: :token
  factory :token_sms_token,      class: Token::SmsToken,      parent: :token
end
