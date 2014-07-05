class DocumentsController < ApplicationController
  layout 'market'

  def show
    @doc = Document.find_by_key(params[:id])

    if not @doc
      redirect_to(request.referer || root_path)
      return
    end

    if @doc.is_auth and !current_user
      render :nothing => true
    end
  end

  def api_v2
    render 'api_v2', layout: 'api_v2'
  end

  def websocket_api
    render 'websocket_api', layout: 'api_v2'
  end

end
