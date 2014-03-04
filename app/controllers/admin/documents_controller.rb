module Admin
  class DocumentsController < BaseController
    prepend_before_filter :find_document, :only => [:show, :update, :edit]
    prepend_before_filter :create_document, :only => :create

    def index
      @documents_grid = ::DocumentsGrid.new(params[:documents_grid])
      @assets = @documents_grid.assets
    end

    def new
      @document.is_auth = false
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
    def find_document
      @document = Document.find_by_key(params[:id])
    end

    def document_params
      params.required(:document).permit(:key, :is_auth, *Document.locale_params)
    end

    def create_document
      @document = Document.new(document_params)
    end
  end
end

