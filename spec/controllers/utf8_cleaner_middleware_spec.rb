require 'spec_helper'

describe UTF8Cleaner::Middleware do

  it { expect(Rails.application.middleware).to be_include(UTF8Cleaner::Middleware) }

  describe 'filter invalid UTF-8 characters from params' do
    let(:app) { proc{[200,{},['Hello, world.']]} }
    let(:stack) { UTF8Cleaner::Middleware.new(app) }
    let(:request) { Rack::MockRequest.new(stack) }
    let(:response) { request.get('/?%22%20onmouseover%3Dprompt(0)%20//') }

    it { expect(response).to be_ok }
  end

end
