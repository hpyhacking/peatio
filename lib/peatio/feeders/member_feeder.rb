class MemberFeeder < AbstractFeeder
  def feed(email, password)
    identity = Identity.find_or_initialize_by(email: email)
    identity.update! \
      password:              password,
      password_confirmation: password,
      is_active:             true

    member = Member.find_or_initialize_by(email: email)
    member.assign_attributes \
      activated:    true,
      nickname:     Faker::Internet.user_name,
      phone_number: Faker::PhoneNumber.cell_phone
    member.authentications = [Authentication.new(provider: 'identity', uid: identity.id)]
    member.save!

    member.id_document.update! \
      name:               Faker::Name.name,
      address:            Faker::Address.street_address,
      city:               Faker::Address.city,
      country:            Faker::Address.country,
      zipcode:            Faker::Address.zip,
      id_document_type:   :id_card,
      id_document_number: Faker::Number.number(15),
      aasm_state:         :verified

    member
  end
end
