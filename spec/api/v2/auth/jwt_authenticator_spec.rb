# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Auth::JWTAuthenticator do
  let :token do
    'Bearer ' + jwt_build(payload)
  end

  let :endpoint do
    stub('endpoint', options: { route_options: { scopes: ['identity'] } })
  end

  let :request do
    stub 'request', \
      request_method: 'GET',
      path_info:      '/members/me',
      env:            { 'api.endpoint'  => endpoint },
      headers:        { 'Authorization' => token }
  end

  let :member do
    create(:member, :level_3)
  end

  let :payload do
    { x: 'x', y: 'y', z: 'z', email: member.email, uid: 'BARONG1234' }
  end

  subject { API::V2::Auth::JWTAuthenticator.new(request.headers['Authorization']) }

  it 'should raise exception when email is not provided' do
    payload.delete(:email)
    expect { subject.authenticate }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /blank/ }
  end

  it 'should raise exception when email is blank' do
    payload[:email] = ''
    expect { subject.authenticate }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /blank/ }
  end

  it 'should raise exception when email is invalid' do
    payload[:email] = '@gmail.com'
    expect { subject.authenticate }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /invalid/ }
  end

  it 'should raise exception when token is expired' do
    payload[:exp] = 1.minute.ago.to_i
    expect { subject.authenticate }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /failed to decode and verify jwt/i }
  end

  it 'should raise exception when state is not active' do
    payload.merge!(level: 1, state: 'disabled', role: 'member' )
    expect { subject.authenticate }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /State is not active./ }
  end

  describe 'on the fly registration' do

    context 'token issued by Barong' do
      before { payload[:iss] = 'barong' }

      it 'should require UID to be not blank' do
        payload.merge!(level: 1, state: 'disabled', email: Faker::Internet.email, uid: ' ')
        expect { subject.authenticate }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /UID is blank/ }
      end

      it 'should register member' do
        payload.merge!(email: 'guyfrombarong@email.com', uid: 'BARONG1234', state: 'active', level: 2, role: 'member')
        expect { subject.authenticate }.to change(Member, :count).by(1)
        record = Member.last
        expect(record.email).to eq payload[:email]
        expect(record.state).to eq 'active'
        expect(record.level).to eq 2
        expect(record.uid).to eq payload[:uid]
      end

      it 'should update member if exists' do
        member = create(:member, :level_1)
        uid    = Faker::Internet.password(12, 12)
        member.update(uid: uid)
        payload.merge!(email: member.email, uid: uid, state: 'active', level: 3, role: 'member')
        expect { subject.authenticate }.not_to change(Member, :count)
        member.reload
        expect(member.email).to eq payload[:email]
        expect(member.level).to eq 3
        expect(member.uid).to eq payload[:uid]
      end
    end
  end
end
