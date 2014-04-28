namespace :i18n do
  desc "migrate simple backend i18n to sqlite backend"
  task migrate: :environment do
    Peatio::I18n::CLI::Migrator.new.migrate
  end
end
