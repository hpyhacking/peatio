class AddDescAndKeywordToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :desc, :text
    add_column :documents, :keyword, :text

    add_column :document_translations, :desc, :text
    add_column :document_translations, :keyword, :text
  end
end
