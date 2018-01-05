class DropDocuments < ActiveRecord::Migration
  def change
    drop_table :documents
    drop_table :document_translations if table_exists?(:document_translations)
  end
end
