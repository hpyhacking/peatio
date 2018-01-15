def sign_in(member)
  inject_session member_id: member.id
  visit settings_path
end
