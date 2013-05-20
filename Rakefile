# -*- coding: utf-8 -*-
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

load File.expand_path('../../lib/tasks/libgss_test.rake', __FILE__)


desc "run spec with server launched"
task :test => [:"libgss_test:check_daemon_alive", :"libgss_test:launch_server_daemons"] do
  # Rake::Task["libgss_test:launch_server_daemons"].execute

  # プロセスが起動してもポートをLISTENするまで時間がかかります。ここでの想定は30秒。
  puts "now waiting to start servers"
  sleep(30)
  begin
    ENV['DEFAULT_HTTP_PORT'] ||= '3000'
    ENV['DEFAULT_HTTPS_PORT'] ||= '3001'
    Rake::Task["spec"].execute
  ensure
    Rake::Task["libgss_test:shutdown_server_daemons"].execute
  end
end

# task :default => :spec
task :default => [:"libgss_test:setup", :test]
