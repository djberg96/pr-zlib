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

puts "=== PR-ZLIB BENCHMARK COMPARISON ==="
puts

# Create test data
test_data = "Hello, World! " * 1000
iterations = 100

puts "Test data size: #{test_data.bytesize} bytes"
puts "Iterations: #{iterations}"
puts "Ruby version: #{RUBY_VERSION}"
puts

Benchmark.bm(20) do |x|
  if stdlib_available
    x.report("stdlib deflate:") do
      iterations.times do
        Zlib::Deflate.deflate(test_data)
      end
    end

    x.report("stdlib inflate:") do
      compressed = Zlib::Deflate.deflate(test_data)
      iterations.times do
        Zlib::Inflate.inflate(compressed)
      end
    end
  end

  x.report("pr-zlib deflate:") do
    iterations.times do
      Zlib::Deflate.deflate(test_data)
    end
  end

  x.report("pr-zlib inflate:") do
    compressed = Zlib::Deflate.deflate(test_data)
    iterations.times do
      Zlib::Inflate.inflate(compressed)
    end
  end
end

puts
puts "=== COMPRESSION RATIO TEST ==="
original_size = test_data.bytesize
if stdlib_available
  stdlib_compressed = Zlib::Deflate.deflate(test_data)
  puts "Original size: #{original_size} bytes"
  puts "Stdlib compressed: #{stdlib_compressed.bytesize} bytes (#{(stdlib_compressed.bytesize.to_f / original_size * 100).round(2)}%)"
end

pr_compressed = Zlib::Deflate.deflate(test_data)
puts "PR-zlib compressed: #{pr_compressed.bytesize} bytes (#{(pr_compressed.bytesize.to_f / original_size * 100).round(2)}%)"

puts
puts "=== COMPATIBILITY TEST ==="
if stdlib_available
  stdlib_result = Zlib::Inflate.inflate(stdlib_compressed)
  pr_result = Zlib::Inflate.inflate(pr_compressed)
  puts "Data integrity: #{test_data == stdlib_result && test_data == pr_result ? 'PASS' : 'FAIL'}"
  puts "Cross-compatibility: #{test_data == Zlib::Inflate.inflate(stdlib_compressed) ? 'PASS' : 'FAIL'}"
else
  pr_result = Zlib::Inflate.inflate(pr_compressed)
  puts "Data integrity: #{test_data == pr_result ? 'PASS' : 'FAIL'}"
end
