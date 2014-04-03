module Private
  class MyAssetsController < BaseController
    def index
      @accounts = current_user.accounts
    end
  end
end
