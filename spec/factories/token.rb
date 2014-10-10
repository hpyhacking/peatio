FactoryGirl.define do
  factory :token do
    member
  end

  factory :activation,     class: Token::Activation,    parent: :token
  factory :reset_password, class: Token::ResetPassword, parent: :token
  factory :sms_token,      class: Token::SmsToken,      parent: :token
end
