module Admin
  class IdDocumentsController < BaseController
    load_and_authorize_resource

    def index
      @id_documents = @id_documents.order(:updated_at).reverse_order.page params[:page]
    end

    def show
    end

    def update
      @id_document.approve! if params[:approve]
      @id_document.reject!  if params[:reject]

      redirect_to admin_id_document_path(@id_document)
    end
  end
end
