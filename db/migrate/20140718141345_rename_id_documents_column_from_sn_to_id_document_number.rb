class RenameIdDocumentsColumnFromSnToIdDocumentNumber < ActiveRecord::Migration
  def change
    rename_column :id_documents, :sn, :id_document_number
  end
end
