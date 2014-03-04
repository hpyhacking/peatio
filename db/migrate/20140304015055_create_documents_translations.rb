class CreateDocumentsTranslations < ActiveRecord::Migration
  def up
    Document.create_translation_table!(
      { :title => :string, :body => :text },
      { :migrate_data => true }
    )
  end

  def down
    Document.drop_translation_table! :migrate_data => true
  end
end
