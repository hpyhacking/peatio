# frozen_string_literal: true

describe API::V2::Account::Deposits, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

	context 'successful' do
		it 'returns info about current member' do
			api_get '/api/v2/account/members/me', token: token
			expect(response).to be_successful
			result = JSON.parse(response.body)
			expect(result['uid']).to eq member.uid
			expect(result['email']).to eq member.email
			expect(result['group']).to eq member.group
		end
	end

	context 'unsuccessful' do
		it 'requires authentication' do
			api_get '/api/v2/account/members/me'
			expect(response.code).to eq '401'
		end
	end
end
