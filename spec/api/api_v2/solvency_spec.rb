describe APIv2::Solvency, type: :request do

  let!(:member) { create(:member, :verified_identity) }
  let(:token) { jwt_for(member) }

  describe 'GET api/v2/solvency/liability_proofs/latest' do
    context 'when no liability proofs available in database' do

      it 'should require authentication' do
        get '/api/v2/solvency/liability_proofs/latest'
        expect(response.code).to eq '401'
      end

      it 'require currency code to be present and to be coin' do
        api_get '/api/v2/solvency/liability_proofs/latest', token: token
        expect(response.code).to eq '422'

        api_get '/api/v2/solvency/liability_proofs/latest', params: { currency: 'usd' }, token: token
        expect(response.code).to eq '422'
      end

      it 'doesn\'t fail if proofs don\'t exist' do
        api_get '/api/v2/solvency/liability_proofs/latest', params: { currency: 'btc' }, token: token

        expect(response.code).to eq '200'
        proof = JSON.parse(response.body)
        expect(proof).to eq nil
      end
    end

    context 'when liability proofs available in database' do
      let!(:proofs) { create_list(:proof, 10) }

      it 'should return liability proof and it should be latest' do
        api_get '/api/v2/solvency/liability_proofs/latest', params: { currency: 'btc' }, token: token

        expect(response.code).to eq '200'
        proof = JSON.parse(response.body)
        expect(proof).not_to eq nil
        expect(proof['id']).to eq proofs.last.id
      end
    end
  end

  describe 'GET api/v2/solvency/liability_proofs/partial_tree/mine' do
    context 'no partial trees available in database' do

      it 'should require authentication' do
        get '/api/v2/solvency/liability_proofs/partial_tree/mine'
        expect(response.code).to eq '401'
      end

      it 'require currency code to be present and to be coin' do
        api_get '/api/v2/solvency/liability_proofs/partial_tree/mine', token: token
        expect(response.code).to eq '422'

        api_get '/api/v2/solvency/liability_proofs/partial_tree/mine', params: { currency: 'usd' }, token: token
        expect(response.code).to eq '422'
      end

      it 'doesn\'t fail if proofs don\'t exist' do
        api_get '/api/v2/solvency/liability_proofs/partial_tree/mine', params: { currency: 'btc' }, token: token

        expect(response.code).to eq '200'
        partial_tree = JSON.parse(response.body)
        expect(partial_tree).to eq nil
      end
    end

    context 'when partial trees available in database' do
      let!(:partial_trees) { create_list(:partial_tree, 10, account: member.get_account(:btc)) }

      it 'should return partial trees and it should be latest' do
        api_get '/api/v2/solvency/liability_proofs/partial_tree/mine', params: { currency: 'btc' }, token: token

        expect(response.code).to eq '200'
        partial_tree = JSON.parse(response.body)
        expect(partial_tree).not_to eq nil
        expect(partial_tree['id']).to eq partial_trees.last.id
      end
    end
  end
end
