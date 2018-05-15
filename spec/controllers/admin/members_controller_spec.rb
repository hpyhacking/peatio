# encoding: UTF-8
# frozen_string_literal: true

describe Admin::MembersController do
  let(:member) { create(:admin_member) }
  before { session[:member_id] = member.id }
end
