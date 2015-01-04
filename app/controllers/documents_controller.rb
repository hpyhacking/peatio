class DocumentsController < ApplicationController

  def show
    @doc = Document.find_by_key(params[:id])
    raise ActiveRecord::RecordNotFound unless @doc

    if @doc.is_auth and !current_user
      redirect_to root_path, alert: t('activations.new.login_required')
    end
  end

  def api_v2
    render 'api_v2', layout: 'api_v2'
  end

  def websocket_api
    render 'websocket_api', layout: 'api_v2'
  end

  def oauth
    render 'oauth', layout: 'api_v2'
  end

end
