# frozen_string_literal: true

describe API::V2::Admin::Engines, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/engines/:id' do
    let(:engine) { Engine.first }

    it 'returns information about specified engine' do
      api_get "/api/v2/admin/engines/#{engine.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq engine.id
      expect(result.fetch('name')).to eq engine.name
      expect(result.fetch('driver')).to eq engine.driver
      expect(result.fetch('state')).to eq engine.state
      expect(result.fetch('url')).to eq nil
    end

    it 'returns error in case of invalid id' do
      api_get "/api/v2/admin/engines/#{Engine.last.id + 1}", token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/engines/#{engine.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/engines' do
    it 'lists of engines' do
      api_get '/api/v2/admin/engines', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq 3
    end

    it 'returns engines by ascending order' do
      api_get '/api/v2/admin/engines', params: { ordering: 'asc' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['id']).to eq Engine.first.id
    end

    it 'returns paginated engines' do
      api_get '/api/v2/admin/engines', params: { limit: 1, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '3'
      expect(result.size).to eq 1

      api_get '/api/v2/admin/engines', params: { limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '3'
      expect(result.size).to eq 1
    end

    it 'return error in case of not permitted ability' do
      api_get '/api/v2/admin/engines', token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/engines/new' do
    let(:engine) { create(:engine) }
    let(:valid_params) do
      {
        name: 'new-engine',
        driver: 'new_driver',
        uid: 'UID123456',
        key: 'your_key',
        secret: 'your_secret',
        state: Engine::STATES.values[0],
        data: { some_data: 'some data' }
      }
    end

    it 'creates new engine' do
      api_post '/api/v2/admin/engines/new', token: token, params: valid_params
      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['name']).to eq 'new-engine'
      expect(result['data'].blank?).to eq true
      expect(result['state']).to eq 'online'

      api_post '/api/v2/admin/engines/new', token: token, params: valid_params
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.engine.duplicate_name')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/engines/new', params: {}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.engine.missing_name')
      expect(response).to include_api_error('admin.engine.missing_driver')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/engines/new', params: valid_params, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/engines/update' do
    it 'updates attributes' do
      api_post '/api/v2/admin/engines/update', params: { id: Engine.first.id, name: 'Second Engine', driver: 'second_driver' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['name']).to eq 'Second Engine'
      expect(result['driver']).to eq 'second_driver'
    end

    it 'updates secret' do
      api_post '/api/v2/admin/engines/update', params: { id: Engine.first.id, secret: 'my_secret' }, token: token

      expect(response).to be_successful
      expect(Engine.first.secret).to eq('my_secret')
    end

    it 'updates uid' do
      api_post '/api/v2/admin/engines/update', params: { id: Engine.first.id, uid: 'ID871263897' }, token: token

      expect(response).to be_successful
      expect(Engine.first.uid).to eq('ID871263897')
    end

    it 'checkes required params' do
      api_post '/api/v2/admin/engines/update', params: {}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.engine.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/engines/update', params: { id: Engine.first.id, name: :new }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
