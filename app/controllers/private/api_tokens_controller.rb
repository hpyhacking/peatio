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
      @token = current_user.api_tokens.build api_token_params

      if !two_factor_auth_verified?
        flash.now[:alert] = t('.alert_two_factor')
        render :new and return
      end

      if @token.save
        flash.now[:notice] = t('.success')
      else
        flash.now[:alert] = t('.failed')
        render :new
      end
    end

    def destroy
      @token = current_user.api_tokens.find params[:id]
      if @token.destroy
        redirect_to url_for(action: :index), notice: t('.success')
      else
        redirect_to url_for(action: :index), notice: t('.failed')
      end
    end

    private

    def api_token_params
      params.require(:api_token).permit(:label)
    end

  end
end
