require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name              = 'pr-zlib'
   gem.version           = '1.0.0'
   gem.authors           = ['Park Heesob', 'Daniel Berger']
   gem.email             = 'phasis@gmail.com'
   gem.homepage          = 'http://www.rubyforge.org/projects/pure'
   gem.rubyforge_project = 'pure'
   gem.platform          = Gem::Platform::RUBY
   gem.summary           = 'Pure Ruby version of the zlib library'
   gem.test_files        = Dir['test/*.rb']
   gem.has_rdoc          = true
   gem.files             = Dir["**/*"].reject{ |f| f.include?('SVN') }
   gem.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']
   
   gem.add_dependency('test-unit', '>= 2.0.2')
   
   gem.description = <<-EOF
      The pr-zlib library is a pure Ruby implementation of both the zlib C
      library, and the Ruby zlib interface that ships as part of the standard
      library.
   EOF
end

if $0 == __FILE__
   Gem::Builder.new(spec).build
end
