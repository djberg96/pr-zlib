## 1.0.6 - 19-Mar-2018
* Added the minirbgzip executable, a Ruby implementation of minigzip.
  Formerly minigzip.rb, this had been part of the repo but had never been
  released with the gem.
* Some minor updates and fixes to the minirbgzip executable.
* Metadata fix for changelog_uri.

## 1.0.5 - 18-Mar-2018
* Set the frozen_string_literal pragma, which gives us a small performance
  boost for reads.
* Removed the custom Fixnum#ord method.
* This library now requires Ruby 2.2 or later
* Added metadata to the gemspec plus some other minor updates.
* Updated cert.

## 1.0.4 - 15-Nov-2016
* Fixed an endian bug. Thanks go to Benoit Daloze for the patch.
* The version constants are now frozen (and fixed the version number).
* Updated the cert.

## 1.0.3 - 3-Dec-2015
* Added a license. This library is now covered under the zlib license.
* Some performance tuning. Reads are 2-3 times faster, while writes are
  about twenty percent faster.
* This gem is now signed.
* Added a pr-zlib.rb file for convenience.
* Use require_relative internally where appropriate.
* More stringent value and limit checking added. Thanks go to
  Chris Seaton for the patches.

## 1.0.2 - 24-Jun-2015
* Fixed a marshalling issue.

## 1.0.1 - 16-Oct-2014
* Added benchmark and profiler scripts and rake tasks.
* Switched profiling scripts to use ruby-prof.
* The test-unit and ruby-prof libraries are now development dependencies.
* Minor updates to eliminate warnings for Ruby 1.9.3 and 2.1.
* Some minor test suite updates, mostly for 1.9.3.
* Updated the gemspec, removed Rubyforge references.

## 1.0.0 - 12-Jun-2009
* Initial release
