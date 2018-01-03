module Private
  class APITokensController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!

    def index
      @tokens = current_user.api_tokens

      ids = APIToken.select('max(id) as id')
      @access_tokens = APIToken.where(id: ids)
    end

    def new
      @token = current_user.api_tokens.build
    end

    def create
      @token = current_user.api_tokens.build api_token_params
      @token.scopes = 'all'

      if @token.save
        flash.now[:notice] = t('.success')
      else
        flash.now[:alert] = t('.failed')
        render :new
      end
    end

    def edit
      @token = current_user.api_tokens.find params[:id]
    end

    def update
      @token = current_user.api_tokens.find params[:id]

      if @token.update_attributes(api_token_params)
        flash.now[:notice] = t('.success')
      else
        flash.now[:alert] = t('.failed')
      end

      render :edit
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
      params.require(:api_token).permit(:label, :ip_whitelist)
    end

  end
end
