module Private
  class IdDocumentsController < BaseController

    def edit
      @id_document = current_user.id_document || current_user.create_id_document
    end

    def update
      @id_document = current_user.id_document
      @id_document.update id_docuemnt_params
      @id_document.submit

      redirect_to settings_path, notice: t('.notice')
    end

    private
    def id_docuemnt_params
      params.require(:id_document).permit(:name, :address, :city, :country, :zipcode, :category, :sn)
    end
  end
end
