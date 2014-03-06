module Private
  class IdDocumentsController < BaseController
    def new
      @id_document = IdDocument.new
    end

    def create
      @id_document = current_user.create_id_document(id_docuemnt_params)
      if @id_document.valid?
        redirect_to settings_path, notice: t('.notice')
      else
        render :new
      end
    end

    private 
    def id_docuemnt_params
      params.require(:id_document).permit(:name, :sn, :category)
    end
  end
end
