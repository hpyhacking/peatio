# encoding: UTF-8
# frozen_string_literal: true

def sign_in(member)
  inject_session member_id: member.id
  visit settings_path
end
