class RenameIdDocumentsColumnCategoryToIdDocumentType < ActiveRecord::Migration
  def change
    rename_column :id_documents, :category, :id_document_type
  end
end
