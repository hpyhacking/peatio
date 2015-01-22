require 'spec_helper'

describe Admin::TwoFactorsController do
  let(:member) { create(:admin_member) }
  let(:sms_two_factor) { member.sms_two_factor }
  let(:app_two_factor) { member.app_two_factor }

  before do
    session[:member_id] = member.id
    two_factor_unlocked
    app_two_factor.active!
    sms_two_factor.active!
    request.env["HTTP_REFERER"] = "where_i_came_from"
  end

  it { expect(sms_two_factor).to be_activated }
  it { expect(app_two_factor).to be_activated }

  it 'deactive sms two_factor' do
    delete :destroy, member_id: member.id, id: sms_two_factor.id
    expect(sms_two_factor.reload).not_to be_activated
  end

  it 'deactive app two_factor' do
    delete :destroy, member_id: member.id, id: app_two_factor.id
    expect(app_two_factor.reload).not_to be_activated
  end
end
