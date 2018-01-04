class CreateDocumentsTranslations < ActiveRecord::Migration
  def up
    # Pessimistic if Globalize is defined and mounted for Document.
    if defined?(Document) && Document.respond_to?(:create_translation_table!)
      Document.create_translation_table!(
        { title: :string, body: :text },
        { migrate_data: true }
      )
    end
  end

  def down
    # Pessimistic if Globalize is defined and mounted for Document.
    if defined?(Document) && Document.respond_to?(:drop_translation_table)
      Document.drop_translation_table!(migrate_data: true)
    end
  end
end
