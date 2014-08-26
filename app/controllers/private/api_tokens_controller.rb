module Private
  class APITokensController < BaseController

    def index
      @tokens = current_user.api_tokens
    end

  end
end
