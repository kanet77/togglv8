require "bundler/gem_tasks"
require 'fileutils'

task :clean do
  FileUtils.remove_dir('coverage', force=true)
  FileUtils.remove_dir('doc', force=true)
  FileUtils.remove_dir('pkg', force=true)
end
