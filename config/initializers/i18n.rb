if Rails.env.development?
  I18n.backend = I18n::Backend::Chain.new(Peatio::I18n::Backend::Sqlite.new, I18n.backend)
end
