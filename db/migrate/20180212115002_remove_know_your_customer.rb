class RemoveKnowYourCustomer < ActiveRecord::Migration
  def change
    drop_table :id_documents
  end
end
