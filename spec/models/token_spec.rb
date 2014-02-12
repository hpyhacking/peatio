require 'spec_helper'

describe Token do
  describe 'before_create' do
    it 'mark old tokens of the same type for the same identity as used' do
      identity = create :identity, :inactive
      old_activation = identity.activation
      reset_password = create :reset_password, identity: identity
      other_activation = create(:identity).activation

      [old_activation, reset_password, other_activation].each do |t|
        expect(t.is_used).to be_false
      end

      Timecop.travel(6.minutes.from_now)
      Activation.create(identity: identity, email: identity.email)

      expect(old_activation.reload.is_used).to be_true
      [reset_password, other_activation].each do |t|
        expect(t.reload.is_used).to be_false
      end
    end
  end
end
