# == Schema Information
#
# Table name: tokens
#
#  id         :integer          not null, primary key
#  token      :string(255)
#  expire_at  :datetime
#  member_id  :integer
#  is_used    :boolean
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Token do
  let(:member) { create :member }

  it 'mark old tokens of the same type for the same identity as used' do
    reset_password = create :reset_password, member: member
    expect(reset_password.is_used).to be_false

    Timecop.travel(6.minutes.from_now)

    new_reset_password = create :reset_password, member: member
    expect(reset_password.reload.is_used).to be_true
    expect(new_reset_password.is_used).to be_false
  end

  it 'dont mark old tokens of the too soon create new one' do
    reset_password = create :reset_password, member: member
    expect(reset_password.is_used).to be_false

    Timecop.travel(4.minutes.from_now)

    expect do
      new_reset_password = create :reset_password, member: member
    end.to raise_error

    expect(reset_password.reload.is_used).to be_false
  end
end
