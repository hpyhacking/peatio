# encoding: UTF-8
# frozen_string_literal: true

class RemoveKnowYourCustomer < ActiveRecord::Migration
  def change
    drop_table :id_documents
  end
end
