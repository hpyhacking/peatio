require 'spec_helper'

describe Token do
  let(:member) { create :member }

  it 'mark old tokens of the same type for the same identity as used' do
    reset_password = create :reset_password, tokenable: member
    reset_two_factor = create :reset_two_factor, tokenable: member

    expect(reset_password.is_used).to be_false
    expect(reset_two_factor.is_used).to be_false

    Timecop.travel(6.minutes.from_now)

    new_reset_password = create :reset_password, tokenable: member
    new_reset_two_factor = create :reset_two_factor, tokenable: member

    expect(reset_password.reload.is_used).to be_true
    expect(reset_two_factor.reload.is_used).to be_true

    expect(new_reset_password.is_used).to be_false
    expect(new_reset_two_factor.is_used).to be_false
  end

  it 'dont mark old tokens of the too soon create new one' do
    reset_password = create :reset_password, tokenable: member
    expect(reset_password.is_used).to be_false

    Timecop.travel(4.minutes.from_now)

    expect do
      create :reset_password, tokenable: member
    end.to raise_error

    expect(reset_password.reload.is_used).to be_false
  end
end
