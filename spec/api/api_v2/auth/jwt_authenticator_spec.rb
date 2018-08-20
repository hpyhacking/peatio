# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Auth::JWTAuthenticator do
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
    { x: 'x', y: 'y', z: 'z', email: member.email }
  end

  subject { APIv2::Auth::JWTAuthenticator.new(request.headers['Authorization']) }

  it 'should work in standard conditions' do
    expect(subject.authenticate!).to eq member.email
  end

  it 'should raise exception when email is not provided' do
    payload.delete(:email)
    expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /blank/ }
  end

  it 'should raise exception when email is blank' do
    payload[:email] = ''
    expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /blank/ }
  end

  it 'should raise exception when email is invalid' do
    payload[:email] = '@gmail.com'
    expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /invalid/ }
  end

  it 'should raise exception when token is expired' do
    payload[:exp] = 1.minute.ago.to_i
    expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /failed to decode and verify jwt/i }
  end

  describe 'exception-safe authentication' do
    it 'should not raise exceptions' do
      payload.delete(:email)
      expect { subject.authenticate }.not_to raise_error
    end
  end

  describe 'authentication options' do
    it 'should return email if return: :email specified' do
      expect(subject.authenticate!(return: :email)).to eq payload[:email]
    end

    it 'should return member if return: :member specified' do
      create(:member)
      payload[:email] = member.email
      expect(subject.authenticate!(return: :member)).to eq member
    end
  end

  describe 'on the fly registration' do
    context 'token not issued by Barong' do
      before { payload[:iss] = 'someone' }
      it 'should not register member unless token is issued by Barong' do
        expect { subject.authenticate! }.not_to change(Member, :count)
      end
    end

    context 'token issued by Barong' do
      before { payload[:iss] = 'barong' }

      it 'should require level to be present in payload' do
        payload.merge!(state: 'pending', uid: Faker::Internet.password(14, 14), email: Faker::Internet.email)
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /key not found: :level/ }
      end

      it 'should require state to be present in payload' do
        payload.merge!(level: 1, uid: Faker::Internet.password(14, 14), email: Faker::Internet.email)
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /key not found: :state/ }
      end

      it 'should require UID to be present in payload' do
        payload.merge!(level: 1, state: 'disabled', email: Faker::Internet.email)
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /key not found: :uid/ }
      end

      it 'should require UID to be not blank' do
        payload.merge!(level: 1, state: 'disabled', email: Faker::Internet.email, uid: ' ')
        expect { subject.authenticate! }.to raise_error(Peatio::Auth::Error) { |e| expect(e.reason).to match /UID is blank/ }
      end

      it 'should register member' do
        payload.merge!(email: 'guyfrombarong@email.com', uid: 'BARONG1234', state: 'active', level: 2)
        expect { subject.authenticate! }.to change(Member, :count).by(1)
        record = Member.last
        expect(record.email).to eq payload[:email]
        expect(record.disabled?).to eq false
        expect(record.level).to eq 2
        expect(record.authentications.last.uid).to eq payload[:uid]
        expect(record.authentications.last.provider).to eq 'barong'
      end

      it 'should update member if exists' do
        member = create(:member, :level_1)
        uid    = Faker::Internet.password(14, 14)
        member.authentications.build(uid: uid, provider: 'barong').save!
        payload.merge!(email: member.email, uid: uid, state: 'blocked', level: 3)
        expect { subject.authenticate! }.not_to change(Member, :count)
        member.reload
        expect(member.email).to eq payload[:email]
        expect(member.disabled?).to eq true
        expect(member.level).to eq 3
        expect(member.authentications.last.uid).to eq payload[:uid]
        expect(member.authentications.last.provider).to eq 'barong'
        expect(member.authentications.count).to eq 1
      end

      it 'should register new member and return instance' do
        payload.merge!(email: 'guyfrombarong@email.com', uid: 'BARONG1234', state: '', level: 100)
        expect(subject.authenticate!(return: :member)).to eq Member.last
        expect(Member.last.level).to eq 100
      end
    end
  end
end
