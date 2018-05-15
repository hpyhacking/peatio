# encoding: UTF-8
# frozen_string_literal: true

YAML.load_file('config/plugins.yml').yield_self { |ary| ary || [] }.each do |plugin|
  relative_path_from_root = plugin.fetch('require') { File.join(plugin.fetch('name'), 'index.rb') }
  next unless relative_path_from_root

  file = File.expand_path(File.join('../../vendor/plugins', relative_path_from_root), __FILE__)
  unless File.file?(file) && File.readable?(file)
    Kernel.abort %[The plugins defined in config/plugins.yml are not installed or installed incorrectly: file "#{file}" doesn't not exist or is not readable by Ruby process. Run "bin/install_plugins" to resolve this issue.]
  end

  begin
    require file
    Kernel.puts %[Loaded plugin "#{plugin.fetch('name')}".]
  rescue Exception => e
    Kernel.abort %[Error caught while loading plugin "#{plugin.fetch('name')}": #{e.inspect}\n#{e.backtrace.join("\n")}]
  end
end if File.exist?('config/plugins.yml')
