namespace :i18n do
  desc "migrate simple backend i18n to sqlite backend"
  task migrate: :environment do
    Peatio::I18n::CLI::Migrator.new.migrate
  end

  desc "dump sqlite backend data to yml"
  task dump_yaml: :environment do
    Peatio::I18n::CLI::Dumper.new.dump
  end
end
