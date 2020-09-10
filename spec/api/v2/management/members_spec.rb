# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Members, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        write_members:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex jeff] },
      }
  end

  describe 'create member' do
    def request
      post_json '/api/v2/management/members', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { build(:member).slice(:uid, :email, :level, :role, :group, :state) }
    let(:signers) { %i[alex jeff] }

    it 'returns member' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to include( data )
    end

    context 'invalid params' do
      context 'email' do
        it 'returns status 422 and error' do
          data[:email] = 'fake_email'

          request
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['errors']).to eq("Validation failed: Email is invalid")
        end
      end

      context 'level' do
        it 'returns status 422 and error' do
          data[:level] = 'fake_level'

          request
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['error']).to eq("level is invalid")
        end
      end

      context 'role' do
        it 'returns status 422 and error' do
          data[:role] = 'fake_role'

          request
          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)['errors']).to eq("Validation failed: Role is not included in the list")
        end
      end
    end
  end

  describe 'set user group' do
    def request
      post_json '/api/v2/management/members/group', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {uid: member.uid, group: 'vip-1'} }
    let(:signers) { %i[alex jeff] }
    let(:member) { create(:member, :barong) }

    it 'returns user with updated role' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['group']).to eq('vip-1')
    end

    context 'invalid uid' do
      let(:data) { { uid: 'fake_uid', group: 'vip-1' }  }
      it 'returns status 404 and error' do
        request
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['error']).to eq("Couldn't find record.")
      end
    end

    context 'invalid record' do
      let(:data) { { uid: member.uid, group: 'vip-12222222222222222222222222222' }  }
      it 'returns status 422 and error' do
        request
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq("Validation failed: Group is too long (maximum is 32 characters)")
      end
    end
  end
end
