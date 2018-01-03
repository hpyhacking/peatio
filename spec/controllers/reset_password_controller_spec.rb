describe ResetPasswordsController, type: :controller do
  before do
    get :new
  end

  it { expect(response).to be_ok }
end
