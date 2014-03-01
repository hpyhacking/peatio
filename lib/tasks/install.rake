namespace :install do

  task :default => :setup

  desc '设定 config 信息'
  task :setup => :database do
  end

  desc '设定数据库'
  task :database do
    username = var '数据库用户名'
    password = var '上述用户的密码'
    config 'config/database.yml' do |content|
      content.gsub! /username: root/, "username: #{username}"
      content.gsub! /password: password/, "password: #{password}"
    end
  end

  private
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

