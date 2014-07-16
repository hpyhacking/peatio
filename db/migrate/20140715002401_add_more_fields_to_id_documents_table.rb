class AddMoreFieldsToIdDocumentsTable < ActiveRecord::Migration
  def change
    add_column :id_documents, :birth_date, :date
    add_column :id_documents, :address, :text
    add_column :id_documents, :city,    :string
    add_column :id_documents, :country, :string
    add_column :id_documents, :zipcode, :string
    add_column :id_documents, :id_bill_type, :integer
  end
end
