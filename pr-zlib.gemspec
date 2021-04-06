require 'rubygems'

Gem::Specification.new do |spec|
  spec.name             = 'pr-zlib'
  spec.version          = '1.0.7'
  spec.authors          = ['Park Heesob', 'Daniel Berger']
  spec.email            = ['phasis@gmail.com', 'djberg96@gmail.com'],
  spec.homepage         = 'https://github.com/djberg96/pr-zlib'
  spec.license          = 'zlib'
  spec.summary          = 'Pure Ruby version of the zlib library'
  spec.test_files       = Dir['test/*.rb']
  spec.files            = Dir["**/*"].reject{ |f| f.include?('git') }
  spec.extra_rdoc_files = ['README', 'CHANGES', 'MANIFEST']
  spec.cert_chain       = Dir['certs/*']
  spec.executables      = 'minirbgzip'

  spec.add_development_dependency('rake')
  spec.add_development_dependency('ruby-prof', '~> 1.4')
  spec.add_development_dependency('test-unit', '~> 3.4')

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/djberg96/pr-zlib',
    'bug_tracker_uri'   => 'https://github.com/djberg96/pr-zlib/issues',
    'changelog_uri'     => 'https://github.com/djberg96/pr-zlib/blob/master/CHANGES',
    'documentation_uri' => 'https://github.com/djberg96/pr-zlib/wiki',
    'source_code_uri'   => 'https://github.com/djberg96/pr-zlib',
    'wiki_uri'          => 'https://github.com/djberg96/pr-zlib/wiki'
  }
   
  spec.description = <<-EOF
    The pr-zlib library is a pure Ruby implementation of both the zlib C
    library, and the Ruby zlib interface that ships as part of the standard
    library.
  EOF
end
