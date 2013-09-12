# -*- coding: utf-8 -*-
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

ENV['DEFAULT_HTTP_PORT'] ||= '3000'
ENV['DEFAULT_HTTPS_PORT'] ||= '3001'

require 'fileutils'

def system!(cmd)
  puts "now executing: #{cmd}"
  IO.popen("#{cmd} 2>&1") do |io|
    while line = io.gets
      puts line
    end
  end

  if $?.exitstatus != 0
    exit(1)
  end
end

desc "test with fontana-LibgssTest"
task :test do
  fileutils = FileUtils::Verbose
  __dir__ = File.expand_path("..", __FILE__)
  sample_dir = File.join(__dir__, "fontana_sample")

  if Dir["#{sample_dir}/*"].empty?
    raise "#{sample_dir} is empty. You have to do `git submodule update --init` before `rake test`"
  end

  fileutils.chdir(sample_dir){ system!("export FONTANA_APP_MODE=test && bundle exec rake vendor:fontana:prepare test:servers:start") }
  begin
    fileutils.chdir(__dir__) do
      Rake::Task["spec"].execute
    end
  ensure
    fileutils.chdir(sample_dir){ system!("rake test:servers:stop") }
  end

  # 最後の子プロセスの終了ステータスで終了します
  exit($?.exitstatus || 1)
end

task :default => :test
