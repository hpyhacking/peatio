module Admin
  class DocumentsController < BaseController
    load_and_authorize_resource find_by: :key

    def index
      @documents_grid = ::DocumentsGrid.new(params[:documents_grid])
      @assets = @documents_grid.assets
    end

    def new
    end

    def create
      if @document.save
        redirect_to admin_documents_path
      else
        render :new
      end
    end

    def show
      render inline: @document.body.html_safe
    end

    def edit
    end

    def update
      if @document.update_attributes(document_params)
        redirect_to admin_documents_path
      else
        render :edit
      end
    end

    def destroy
    end

    private

    def document_params
      params.required(:document).permit(:key, :is_auth, *Document.locale_params)
    end

  end
end

