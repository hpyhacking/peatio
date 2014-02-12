module Concerns
  module TokenManagement
    extend ActiveSupport::Concern

    def token_required
      @token = Token.available.with_token(params[:token] || params[:id]).first
      unless @token
        redirect_to root_path, :error => 'Invalid token'
      end
    end
  end
end
