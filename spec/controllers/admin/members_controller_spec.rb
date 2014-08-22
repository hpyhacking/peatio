require 'spec_helper'

describe Admin::MembersController do
  let(:member) { create(:admin_member) }
  before { session[:member_id] = member.id }

end
