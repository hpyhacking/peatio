class MemberFeeder < AbstractFeeder
  def feed(email)
    Member.transaction do
      member = Member.find_or_initialize_by(email: email)
      member.assign_attributes \
        name:     Faker::Name.name,
        nickname: Faker::Internet.user_name,
        level:    :identity_verified
      member.save!
      member
    end
  end
end
