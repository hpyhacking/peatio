# -*- encoding: UTF-8 -*-
namespace :install do

  desc 'setup database'
  task :database do
    username = var 'username of database'
    password = var 'password of database'
    config 'config/database.yml' do |content|
      content.gsub! /\s{2}username:(.*)$/, "  username: #{username}"
      content.gsub! /\s{2}password:(.*)$/, "  password: #{password}"
    end
  end

  desc 'setup your application'
  task :application do
    if yes_no('Use your own Pusher Account? ')
      pusher_app    = var 'Pusher App: '
      pusher_key    = var 'Pusher Key: '
      pusher_secret = var 'Pusher Secret: '
    end

    if yes_no('Do you want to setup SMTP service')
      smtp_domain = var 'SMTP domain: '
      smtp_address = var 'SMTP address: '
      smtp_username = var 'SMTP username: '
      smtp_password = var 'SMTP password: '
    end

    config 'config/application.yml' do |content|
      lines = content.split /\n/
      lines = customize 'PUSHER_APP',    pusher_app,    lines
      lines = customize 'PUSHER_KEY',    pusher_key,    lines
      lines = customize 'PUSHER_SECRET', pusher_secret, lines
      if smtp_address
        lines = customize 'SMTP_DOMAIN',   smtp_domain, lines
        lines = customize 'SMTP_ADDRESS',  smtp_address, lines
        lines = customize 'SMTP_USERNAME', smtp_username, lines
        lines = customize 'SMTP_PASSWORD', smtp_password, lines
      end
      lines.join "\n"
    end
  end

  private
  def customize key, value, lines
    if value.nil?
      s = lines.find{|str| str=~/# #{key}/}
      value = $1 if s =~ /: +(.+)/
    end
    lines.map do |str|
      if str =~ /[^#] +#{key}:/
        "#{str.split(/:/).first}: #{value}"
      else
        str
      end
    end
  end

  def config filename, &block
    desc = "> File exist! [ #{filename} ]，overwrite?"
    if !File.exist?(filename) || yes_no(desc)
      write filename, &block
    end
  end

  def write filename
    File.open(filename,'w') do |f|
      content = File.read("#{filename}.example") rescue nil
      f.write(yield content)
    end
  end

  def yes_no desc
    while answer=input("#{desc}[y/n]")
      case answer
        when /^[yY](es)?/ then break true
        when /^[nN]o?/    then break false
      end
    end
  end

  def var name
    input"> Please input #{name}："
  end

  def input desc
    print desc
    $stdin.readline.chop
  end
end

task :install => ['install:database','install:application']
