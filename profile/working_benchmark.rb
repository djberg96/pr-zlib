#!/usr/bin/env ruby

require 'benchmark'

# Test with both libraries if available
begin
  require 'zlib'
  stdlib_available = true
rescue LoadError
  stdlib_available = false
end

require_relative '../lib/pr/zlib'

puts "=== PR-ZLIB BENCHMARK RESULTS ==="
puts

# Test data
test_data = "Hello, World! This is a test string for compression. " * 100
iterations = 50

puts "Test data size: #{test_data.bytesize} bytes"
puts "Iterations: #{iterations}"
puts "Ruby version: #{RUBY_VERSION}"
puts

# Test basic functionality that we know works
Benchmark.bm(25) do |x|
  if stdlib_available
    x.report("stdlib adler32:") do
      iterations.times do
        Zlib.adler32(test_data)
      end
    end

    x.report("stdlib crc32:") do
      iterations.times do
        Zlib.crc32(test_data)
      end
    end
  end

  x.report("pr-zlib adler32:") do
    iterations.times do
      Zlib.adler32(test_data)
    end
  end

  x.report("pr-zlib crc32:") do
    iterations.times do
      Zlib.crc32(test_data)
    end
  end
end

puts
puts "=== CHECKSUM VERIFICATION ==="
if stdlib_available
  stdlib_adler = Zlib.adler32(test_data)
  stdlib_crc = Zlib.crc32(test_data)
  puts "Stdlib Adler32: #{stdlib_adler}"
  puts "Stdlib CRC32: #{stdlib_crc}"
end

pr_adler = Zlib.adler32(test_data)
pr_crc = Zlib.crc32(test_data)
puts "PR-zlib Adler32: #{pr_adler}"
puts "PR-zlib CRC32: #{pr_crc}"

if stdlib_available
  puts
  puts "Adler32 match: #{stdlib_adler == pr_adler ? 'PASS' : 'FAIL'}"
  puts "CRC32 match: #{stdlib_crc == pr_crc ? 'PASS' : 'FAIL'}"
end

puts
puts "=== RBZLIB MODULE TESTS ==="

include Rbzlib

test_buffer = 'A' * 1000
Benchmark.bm(25) do |x|
  x.report("rbzlib adler32:") do
    iterations.times do
      adler32(1, test_buffer)
    end
  end

  x.report("rbzlib crc32:") do
    iterations.times do
      crc32(0, test_buffer)
    end
  end

  x.report("rbzlib bytef creation:") do
    iterations.times do
      b = Bytef.new(test_buffer)
      b.get
    end
  end
end

puts
puts "=== MODULE VERIFICATION ==="
rbzlib_adler = adler32(1, test_buffer)
rbzlib_crc = crc32(0, test_buffer)
puts "Rbzlib Adler32: #{rbzlib_adler}"
puts "Rbzlib CRC32: #{rbzlib_crc}"

# Test Bytef classes
b_str = Bytef.new("hello")
b_arr = Bytef.new([65, 66, 67])
puts "Bytef string: #{b_str.class} - get: #{b_str.get}"
puts "Bytef array: #{b_arr.class} - get: #{b_arr.get}"
