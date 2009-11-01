require 'rake'
require 'rake/testtask'
require 'rbconfig'

desc 'Install the pr-zlib library'
task :install do
   install_dir = File.join(Config::CONFIG['sitelibdir'], 'pr')
   Dir.mkdir(install_dir) unless File.exists?(install_dir)
   files = ['lib/pr/zlib.rb', 'lib/pr/rbzlib.rb']
   files.each{ |file|
      FileUtils.cp(file, install_dir, :verbose => true)
   }
end

desc 'Install the pr-zlib library as zlib'
task :install_as_zlib do
   install_dir = File.join(Config::CONFIG['sitelibdir'], 'pr')
   Dir.mkdir(install_dir) unless File.exists?(install_dir)

   FileUtils.cp('lib/pr/zlib.rb', Config::CONFIG['sitelibdir'], :verbose => true)
   FileUtils.cp('lib/pr/rbzlib.rb', install_dir, :verbose => true)
end

desc 'Install the pr-zlib library as a gem'
task :install_gem do
   ruby 'pr-zlib.gemspec'
   file = Dir["*.gem"].first
   sh "gem install #{file}"
end

Rake::TestTask.new do |t|
   t.warning = true
   t.verbose = true   
end

Rake::TestTask.new('test_zlib') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_zlib.rb']
end

Rake::TestTask.new('test_gzip_file') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_zlib_gzip_file.rb']
end

Rake::TestTask.new('test_gzip_reader') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_zlib_gzip_reader.rb']
end

Rake::TestTask.new('test_gzip_writer') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_zlib_gzip_writer.rb']
end

Rake::TestTask.new('test_deflate') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_zlib_deflate.rb']
end

Rake::TestTask.new('test_inflate') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_zlib_inflate.rb']
end

Rake::TestTask.new('test_rbzlib') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_rbzlib.rb']
end

Rake::TestTask.new('test_rbzlib_bytef') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_rbzlib_bytef.rb']
end

Rake::TestTask.new('test_rbzlib_posf') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_rbzlib_posf.rb']
end
