class DropDocuments < ActiveRecord::Migration
  def change
    drop_table :documents
    drop_table :document_translations
  end
end
