require 'spec_helper'

describe SessionsController do
  let(:identity) { create :identity, member: create(:member) }

  describe 'POST create' do
    before do
      controller.stubs(:env).returns({ "omniauth.auth" => stub(uid: '123') })
      Identity.stubs(:find).returns(identity)
      Member.stubs(:from_auth).returns(identity.member)
    end

    let(:do_request) { post :create, auth_key: identity.email, password: "Password123" }

    context 'when retry_count is more than max' do
      before do
        identity.update_attributes(retry_count: 5)
      end

      it 'prevent sign-in even if correct password is provided' do
        do_request
        expect(session[:identity_id]).to be_nil
      end

      it 'shows flash message to notify account locked' do
        do_request
        expect(flash[:error]).to eq(I18n.t 'sessions.failure.account_locked')
      end
    end

    context 'when retry_count is less than max' do
      before do
        identity.update_attributes(retry_count: 4)
      end

      it 'resets retry_count if correct password is provided' do
        expect {
          do_request
        }.to change{ identity.reload.retry_count }.to(0)
      end

      it 'signs in user if correct password is provided' do
        do_request
        expect(session[:identity_id]).to eq(identity.id)
      end
    end
  end

  describe 'GET failure' do
    let(:do_request) { get :failure, auth_key: identity.email, password: "Password1" }

    it 'increment retry_count on the identity' do
      expect {
        do_request
      }.to change { identity.reload.retry_count }.from(nil).to(1)
    end

    context 'when retry_count reaches 5' do
      before do
        identity.update_attributes(retry_count: 4)
      end

      it 'shows flash message to notify account locked' do
        do_request
        expect(flash[:error]).to eq(I18n.t 'sessions.failure.account_locked')
      end
    end
  end
end
