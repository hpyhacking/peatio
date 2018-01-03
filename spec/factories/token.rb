FactoryBot.define do
  factory :token do
    member
  end

  factory :activation,     class: Token::Activation,    parent: :token
  factory :reset_password, class: Token::ResetPassword, parent: :token
end
