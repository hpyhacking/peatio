# frozen_string_literal: true

describe API::V2::Management::Engines, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_engines:  { permitted_signers: %i[alex jeff],       mandatory_signers: %i[alex] },
        write_engines: { permitted_signers: %i[alex jeff james], mandatory_signers: %i[alex jeff] }
      }
  end

  describe 'POST /engines/get' do
    def request
      post_json "/api/v2/management/engines/get", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :read_engines) }

    let(:params) do
      engines_params
    end

    context do
      let(:engines_params) { {} }

      it 'lists of engines' do
        request
        expect(response).to be_successful

        result = JSON.parse(response.body)
        expect(result.size).to eq 2
      end
    end

    context do
      let(:engines_params) do
        {
          ordering: 'asc'
        }
      end

      it 'returns engines by ascending order' do
        request
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.first['id']).to eq Engine.first.id
      end
    end

    context do
      let(:engines_params) do
        {
          name: Engine.first.name
        }
      end

      it 'returns engines by name' do
        request
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.first['id']).to eq Engine.first.id
        expect(result.first['name']).to eq Engine.first.name
      end
    end

    context do
      let(:engines_params) do
        {
          limit: 1,
          page: 1
        }
      end

      it 'returns paginated engines' do
        request
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '2'
        expect(result.size).to eq 1

        params[:page] = 2
        request
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(response.headers.fetch('Total')).to eq '2'
        expect(result.size).to eq 1
      end
    end
  end

  describe 'POST /engines/new' do
    def request
      post_json "/api/v2/management/engines/new", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_engines) }

    let(:params) do
      engines_params
    end

    context do
      let(:engines_params) do
        {
          name: 'new-engine',
          driver: 'new_driver',
          uid: 'UID123456',
          key: 'your_key',
          secret: 'your_secret',
          url: 'your_url',
          state: 1,
          data: { some_data: 'some data' }
        }
      end

      it 'creates new engine' do
        request

        result = JSON.parse(response.body)
        expect(response).to be_successful
        expect(result['name']).to eq 'new-engine'
        expect(result['data'].blank?).to eq true
        expect(result['state']).to eq 'online'
        expect(result['url']).to eq 'your_url'

        request
        expect(response).to have_http_status 422
        result = JSON.parse(response.body)
        expect(result['error']).to include('management.engine.duplicate_name')
      end
    end

    context do
      let(:engines_params) { {} }
      it 'checked required params' do
        request

        expect(response).to have_http_status 422
        result = JSON.parse(response.body)
        expect(result['error']).to include('name is missing, driver is missing')
      end
    end
  end

  describe 'POST /engines/update' do
    def request
      post_json "/api/v2/management/engines/update", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { params.merge(scope: :write_engines) }

    let(:params) do
      engines_params
    end

    let!(:engine) { create(:engine) }

    context do
      let(:engines_params) do
        {
          id: engine.id,
          name: 'Second Engine',
          driver: 'second_driver'
        }
      end

      it 'updates attributes' do
        request
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result['name']).to eq 'Second Engine'
        expect(result['driver']).to eq 'second_driver'
      end
    end

    context do
      let(:engines_params) do
        {
          id: engine.id,
          name: 'Second Engine',
          secret: 'my_secret'
        }
      end

      it 'updates secret' do
        request
        expect(response).to be_successful
        engine.reload
        expect(engine.secret).to eq('my_secret')
      end
    end

    context do
      let(:engines_params) { {} }
      it 'checkes required params' do
        request

        expect(response).to have_http_status 422
        result = JSON.parse(response.body)
        expect(result['error']).to include('id is missing')
      end
    end
  end
end
