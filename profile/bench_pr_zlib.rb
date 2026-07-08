########################################################################
# This benchmarks pr-zlib, the pure Ruby zlib implementation.
#
# You can run this benchmark via the bench:przlib Rake task.
########################################################################
require 'pr/zlib'
require 'benchmark'
require_relative 'support'

MAX = ProfileSupport.env_int('BENCH_ITERATIONS', 10)
LINES = ProfileSupport.env_int('BENCH_LINES', ProfileSupport::DEFAULT_BENCH_LINES)
WARMUP = ProfileSupport.env_int('BENCH_WARMUP', 1)

FILE_NAME = "benchmark.txt"
GZ_FILE_NAME = "benchmark.txt.gz"

ProfileSupport.create_text_file(FILE_NAME, lines: LINES)
input = File.binread(FILE_NAME)

ProfileSupport.report_config(
  'Running the benchmarks for pr-zlib',
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
