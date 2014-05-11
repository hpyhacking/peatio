class WithdrawGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :code, :type => :string
  argument :symbol, :type => :string, :default => '#'

  def copy_initializer_file
    template "model.rb.erb", "app/models/withdraws/#{name.underscore}.rb"
    template "controller.rb.erb", "app/controllers/private/withdraws/#{name.underscore.pluralize}_controller.rb"
    template "locales/zh-CN.yml.erb", "config/locales/withdraws/#{name.underscore.pluralize}/zh-CN.yml"
    template "locales/en.yml.erb", "config/locales/withdraws/#{name.underscore.pluralize}/en.yml"
    template "views/new.html.slim.erb", "app/views/private/withdraws/#{name.underscore.pluralize}/new.slim"
    template "views/edit.html.slim.erb", "app/views/private/withdraws/#{name.underscore.pluralize}/edit.slim"
  end
end
