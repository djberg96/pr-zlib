########################################################################
# This benchmarks the zlib library that ships as part of the Ruby
# standard library.
#
# You can run this benchmark via the bench-zlib Rake task.
########################################################################
require 'zlib'
require 'benchmark'
require_relative 'support'

MAX = ProfileSupport.env_int('BENCH_ITERATIONS', 200)
LINES = ProfileSupport.env_int('BENCH_LINES', ProfileSupport::DEFAULT_BENCH_LINES)
WARMUP = ProfileSupport.env_int('BENCH_WARMUP', 5)

FILE_NAME = "benchmark.txt"
GZ_FILE_NAME = "benchmark.txt.gz"

ProfileSupport.create_text_file(FILE_NAME, lines: LINES)
input = File.binread(FILE_NAME)

ProfileSupport.report_config(
  'Running the benchmarks for zlib (stdlib)',
  iterations: MAX,
  lines: LINES,
  file: FILE_NAME
)

Zlib::GzipWriter.open(GZ_FILE_NAME) { |gz| gz.write(input) }

WARMUP.times do
  Zlib::GzipWriter.open(GZ_FILE_NAME) { |gz| gz.write(input) }
  Zlib::GzipReader.open(GZ_FILE_NAME) { |gz| gz.read }
end

Benchmark.bm do |x|
  x.report("write") do
    GC.start
    MAX.times{
      Zlib::GzipWriter.open(GZ_FILE_NAME) do |gz|
        gz.write(input)
      end
    }
  end

  x.report("read") do
    GC.start
    MAX.times{
      Zlib::GzipReader.open(GZ_FILE_NAME) do |gz|
        gz.read
      end
    }
  end
end

ProfileSupport.cleanup(FILE_NAME, GZ_FILE_NAME)
