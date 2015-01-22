module Private
  class APITokensController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!
    before_action :two_factor_activated!

    def index
      @tokens = current_user.api_tokens.user_requested
      @oauth_api_tokens = current_user.api_tokens.oauth_requested

      ids = Doorkeeper::AccessToken
        .where(id: @oauth_api_tokens.map(&:oauth_access_token_id))
        .group(:application_id).select('max(id) as id')
      @oauth_access_tokens = Doorkeeper::AccessToken.where(id: ids).includes(:application)
    end

    def new
      @token = current_user.api_tokens.build
    end

    def create
      @token = current_user.api_tokens.build api_token_params
      @token.scopes = 'all'

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

    def edit
      @token = current_user.api_tokens.user_requested.find params[:id]
    end

    def update
      @token = current_user.api_tokens.user_requested.find params[:id]

      if !two_factor_auth_verified?
        flash.now[:alert] = t('.alert_two_factor')
        render :edit and return
      end

      if @token.update_attributes(api_token_params)
        flash.now[:notice] = t('.success')
      else
        flash.now[:alert] = t('.failed')
      end

      render :edit
    end

    def destroy
      @token = current_user.api_tokens.user_requested.find params[:id]
      if @token.destroy
        redirect_to url_for(action: :index), notice: t('.success')
      else
        redirect_to url_for(action: :index), notice: t('.failed')
      end
    end

    def unbind
      Doorkeeper::AccessToken.revoke_all_for(params[:id], current_user)
      redirect_to url_for(action: :index), notice: t('.success')
    end

    private

    def api_token_params
      params.require(:api_token).permit(:label, :ip_whitelist)
    end

  end
end
