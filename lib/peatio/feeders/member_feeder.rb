class MemberFeeder < AbstractFeeder
  def feed(email)
    Member.transaction do
      member = Member.find_or_initialize_by(email: email)
      member.assign_attributes(nickname: Faker::Internet.user_name)
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
end
