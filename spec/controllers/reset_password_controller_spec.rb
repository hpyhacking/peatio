require 'spec_helper'

describe ResetPasswordsController do
  before do
    get :new
  end

  it { expect(response).to be_ok }

end
