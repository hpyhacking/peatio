class RemoveColumnVerifiedFromIdDocuments < ActiveRecord::Migration
  def change
    remove_column :id_documents, :verified
  end
end
