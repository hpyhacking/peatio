namespace :peatio do
  namespace :test do
    desc 'Fill database with fake data'
    task tearup: :environment do
      [MembersFeeder.new, AdminsFeeder.new].each(&:feed)
    end

    desc 'Cleanup database from fake data'
    task teardown: :environment do
      Rails.application.eager_load!

      ActiveRecord::Base.descendants.each do |model|
        next if model <= ActiveRecord::SchemaMigration
        next unless model.table_name.in?(ActiveRecord::Base.connection.tables)

        # Delete all records including soft-deleted.
        model.unscoped.tap { |q| (q.try(:with_deleted) || q).delete_all }
      end
    end
  end
end
