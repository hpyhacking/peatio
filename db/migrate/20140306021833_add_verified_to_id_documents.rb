class AddVerifiedToIdDocuments < ActiveRecord::Migration
  def change
    add_column :id_documents, :verified, :boolean
  end
end
