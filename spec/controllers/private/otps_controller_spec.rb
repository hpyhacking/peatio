require 'spec_helper'

describe Private::OtpsController do
  let(:identity) { create :identity }

  before do
    session[:identity_id] = identity.id
  end

  describe '#destroy' do
    before do
      identity.create_two_factor
      identity.two_factor.update_attributes(activated: true)
    end

    context 'valid password' do
      let(:do_request) { delete :destroy, password: 'Password123' }

      it 'resets two factor auth' do
        expect do
          do_request
          identity.reload
        end.to change { identity.two_factor.activated? }.from(true).to(false)
      end
    end

    context 'invalid password' do
      let(:do_request) { delete :destroy, password: '' }

      it 'sets flash error' do
        do_request
        expect(flash[:alert]).to eq I18n.t('invalid_password')
      end

      it 'does not reset two factor auth' do
        expect do
          do_request
          identity.reload
        end.to_not change { identity.two_factor.activated? }
      end
    end
  end
end
