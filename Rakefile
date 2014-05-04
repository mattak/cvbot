# require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new("unittest") do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = true
  t.verbose = true
end

task :run do
  `bundle exec ruby bin/cvbot`
end

task :default => :unittest
