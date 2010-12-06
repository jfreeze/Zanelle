# This file is for the "rake" tool which automates project-related tasks. If you need to automate things, you can create
# a new Rake task here. See http://rake.rubyforge.org for more info.
$LOAD_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)), 'components', 'zanelle', 'lib'))


require 'rubygems'
require 'yaml'
require 'config'
include Zanelle::Config

@config = load_config

def set_shebang(file, value)
  lines = File.read(file).split(/\n/)
  lines[0] = "#!#{value}"
  File.open(file, 'w') { |f| f.puts lines.join("\n") }
end

def backup(set)
  case set
  when :db
  when :yml
  end
end

desc "Push code to remote asterisk box"
task :push_to_remote do
  cmd = "rsync -avP --exclude adhearsion.log --delete #{File.dirname(__FILE__)} root@192.168.75.50:/opt/depot/"
  puts cmd
  puts `#{cmd}`
end

desc "Set web GUI shebang to ensure it starts on reboot."
task :shebang_for_test do
  phone_rb = File.join(ROOT, 'www', 'phone.rb')
  set_shebang(phone_rb, '/usr/bin/env ruby')
end

desc "Set web GUI shebang to ensure it starts on reboot."
task :shebang_for_production do
  phone_rb = File.join(ROOT, 'www', 'phone.rb')
  shebang = @config[:www][:ruby_path] || `which ruby`.strip
  set_shebang(phone_rb, WWW_CONFIG[:ruby_path])
end

desc "Copy yml config to database. (Overwrites database)"
task :copy_yml_to_db do
  backup(:db)
end

desc "Copy database to yml file. (Overwrites yml)"
task :copy_db_to_yml do
  backup(:yml)
end
