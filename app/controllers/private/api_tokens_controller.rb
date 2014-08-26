module Private
  class APITokensController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!
    before_action :two_factor_activated!

    def index
      @tokens = current_user.api_tokens
    end

    def new
      @token = current_user.api_tokens.build
    end

    def create
      if !two_factor_auth_verified?
        redirect_to url_for(action: :new), alert: t('.alert_two_factor')
        return
      end

      @token = current_user.api_tokens.build api_token_params
      if @token.save
        redirect_to url_for(action: :index), notice: t('.success')
      else
        redirect_to url_for(action: :index), alert: t('.failed')
      end
    end

    private

    def api_token_params
      params.require(:api_token).permit(:label)
    end

  end
end
