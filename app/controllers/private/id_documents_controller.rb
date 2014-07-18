module Private
  class IdDocumentsController < BaseController

    def edit
      @id_document = current_user.id_document || current_user.create_id_document
    end

    def update
      @id_document = current_user.id_document

      if @id_document.update_attributes id_docuemnt_params
        @id_document.submit if @id_document.unapproved?
        redirect_to settings_path, notice: t('.notice')
      else
        render :edit
      end
    end

    private

    def id_docuemnt_params
      params.require(:id_document).permit(:name, :birth_date, :address, :city, :country, :zipcode,
                                          :category, :sn, :id_bill_type,
                                          {id_document_file_attributes: [:id, :file]},
                                          {id_bill_file_attributes: [:id, :file]})
    end
  end
end
