## Description
The pr-zlib library is a pure Ruby version of the zlib compression library.
It consists of both a port of zlib.h and the Ruby zlib library that ships as
part of the standard library.

## Installation
`gem install pr-zlib`

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/pr-zlib/main/certs/djberg96_pub.pem)`

## Synopsis
```ruby
# Imitating a bit of code used in rubygems
require 'pr/zlib'
require 'stringio'

data = StringIO.new(data)
Zlib::GzipReader.new(data).read
```

## Motivation
First, building the zlib C library on MS Windows with Visual C++ is very
difficult. However, certain libraries depend on zlib, most notably rubygems.
By providing a pure Ruby version we eliminate any compiler or platform
compatability issues.

Second, even some Unix distributions, such as Debian, do not ship with
the zlib library by default. By creating a pure Ruby version of the zlib
library we eliminate the need to install a 3rd party C library, and
eliminate a potential weak link in the dependency chain.

Third, by creating pure Ruby versions of the library and the interface we
are more likely to receive patches, feature requests, documentation updates,
etc, from the Ruby community since not everyone who knows Ruby also knows C.

Last, the zlib interface that ships as part of the stdlib is a little on the
clunky side. By providing a pure Ruby version, authors can create their own
interface as they see fit.

## Origins
This library was the result of a small code bounty that I (Daniel Berger) funded:

https://rubytalk.org/t/bounty-pure-ruby-zlib-gzipwriter/50730

## TODO
More tests, and better tests, are needed for both Rbzlib and Zlib.

## Caveats
You cannot use both this library and the zlib standard library at the same
time. If you try to use both there is a good chance you will get an allocation
error of some sort. If you already have zlib, you do not need this library.

## License
This library is covered under the same license as zlib itself. For the text
of the zlib license, please see http://zlib.net/zlib_license.html.

## Authors
* Park Heesob (C translation)
* Daniel Berger (Testing, packaging, deployment)
