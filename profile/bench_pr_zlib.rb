########################################################################
# This benchmarks the zlib library that ships as part of the Ruby
# standard library.
#
# You can run this benchmark via the bench:przlib Rake task.
########################################################################
require 'pr/zlib'
require 'benchmark'

MAX = 50

print "\n\n== Running the benchmarks for pr-zlib using #{MAX} iterations ==\n\n"

# First, let's create a ~7 MB text file.

FILE_NAME = "benchmark.txt"
GZ_FILE_NAME = "benchmark.txt.gz"

File.open(FILE_NAME, "w") do |fh|
  10000.times{ |x|
    s = "Now is the time for #{x} good men to come to the aid of their country."
    fh.puts s
  }
end

Benchmark.bm do |x|
  x.report("write") do
    MAX.times{
      Zlib::GzipWriter.open(GZ_FILE_NAME) do |gz|
        gz.write(File.read(FILE_NAME))
      end
    }
  end

  x.report("read") do
    MAX.times{
      Zlib::GzipReader.open(GZ_FILE_NAME) do |gz|
        gz.read
      end
    }
  end
end

File.delete(FILE_NAME) if File.exist?(FILE_NAME)
File.delete(GZ_FILE_NAME) if File.exist?(GZ_FILE_NAME)
