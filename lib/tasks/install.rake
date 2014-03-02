# -*- encoding: UTF-8 -*-
namespace :install do

  desc '设定数据库'
  task :database do
    username = var '数据库用户名'
    password = var '上述用户的密码'
    config 'config/database.yml' do |content|
      content.gsub! /username: root/,     "username: #{username}"
      content.gsub! /password: password/, "password: #{password}"
    end
  end

  desc '设定应用配置'
  task :application do
    if yes_no('是否自己设定 Pusher 帐号？')
      pusher_app    = var 'Pusher App: '
      pusher_key    = var 'Pusher Key: '
      pusher_secret = var 'Pusher Secret: '
    end

    if yes_no('是否自己设定 reCaptcha 服务帐号？')
      recaptcha_public_key  = var 'reCaptcha public key: '
      recaptcha_private_key = var 'reCaptcha private key: '
    end

    if yes_no('是否设定 SMTP 服务？')
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
      lines = customize 'RECAPTCHA_PUBLIC_KEY',  recaptcha_public_key,  lines
      lines = customize 'RECAPTCHA_PRIVATE_KEY', recaptcha_private_key, lines
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
    desc = "> 文件已存在[ #{filename} ]，是否覆盖？"
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
    input"> 请输入#{name}："
  end

  def input desc
    print desc
    $stdin.readline.chop
  end
end

task :install => ['install:database','install:application']
