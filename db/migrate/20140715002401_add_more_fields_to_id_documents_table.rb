class AddMoreFieldsToIdDocumentsTable < ActiveRecord::Migration
  def change
    add_column :id_documents, :address, :text
    add_column :id_documents, :zipcode, :string
    add_column :id_documents, :country, :string
  end
end
