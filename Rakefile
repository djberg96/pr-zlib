require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rbconfig'

CLEAN.include("**/*.rbc", "**/*.gem", "**/*.txt", "**/*.gz", "**/*.lock")

desc 'Install the pr-zlib library as zlib'
task :install_as_zlib do
  install_dir = File.join(RbConfig::CONFIG['sitelibdir'], 'pr')
  Dir.mkdir(install_dir) unless File.exists?(install_dir)

  cp('lib/pr/zlib.rb', RbConfig::CONFIG['sitelibdir'], :verbose => true)
  cp('lib/pr/rbzlib.rb', install_dir, :verbose => true)
end

namespace :gem do
  desc 'Create the pr-zlib gem'
  task :create => :clean do
    require 'rubygems/package'
    spec = eval(IO.read('pr-zlib.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc 'Install the pr-zlib gem'
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

namespace :bench do
  desc "Run the zlib benchmark"
  task :zlib do
    Dir.chdir('profile'){ ruby "bench_zlib.rb" }
  end

  desc "Run the pr-zlib benchmark"
  task :przlib do
    sh "ruby -Ilib profile/bench_pr_zlib.rb"
  end
end

namespace :profile do
  desc "Run the profiler on the write operation"
  task :write do
    sh "ruby -Ilib profile/profile_pr_zlib_write.rb"
  end

  desc "Run the profiler on the read operation"
  task :read do
    sh "ruby -Ilib profile/profile_pr_zlib_read.rb"
  end
end

# RSpec tests
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = ['--format', 'documentation', '--color']
end

desc 'Run all RSpec tests'
task :test => :spec

task :default => :spec
