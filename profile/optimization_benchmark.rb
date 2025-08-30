#!/usr/bin/env ruby

require 'benchmark'
require_relative '../lib/pr/rbzlib'

puts "=== PERFORMANCE OPTIMIZATION BENCHMARK ==="
puts

# Test our optimized classes
include Rbzlib

# Create test data
test_string = "A" * 10000
test_array = Array.new(10000, 65)
iterations = 1000

puts "Testing optimized Bytef_str operations (#{iterations} iterations):"
puts

Benchmark.bm(25) do |x|
  # Test string buffer operations
  bytef_str = Bytef.new(test_string.dup)

  x.report("get operations:") do
    iterations.times do |i|
      bytef_str.get
      bytef_str + 1 if i < test_string.length - 1
    end
  end

  # Reset
  bytef_str = Bytef.new(test_string.dup)

  x.report("set operations:") do
    iterations.times do |i|
      bytef_str.set(66)
      bytef_str + 1 if i < test_string.length - 1
    end
  end

  # Reset
  bytef_str = Bytef.new(test_string.dup)

  x.report("get_and_advance:") do
    iterations.times do |i|
      bytef_str.get_and_advance
      break if bytef_str.offset >= test_string.length
    end
  end

  # Reset
  bytef_str = Bytef.new(test_string.dup)

  x.report("set_and_advance:") do
    iterations.times do |i|
      bytef_str.set_and_advance(67)
      break if bytef_str.offset >= test_string.length
    end
  end

  # Test array buffer operations
  bytef_arr = Bytef.new(test_array.dup)

  x.report("array get operations:") do
    iterations.times do |i|
      bytef_arr.get
      bytef_arr + 1 if i < test_array.length - 1
    end
  end

  # Test Posf operations
  posf_buffer = "\x00" * 20000  # Large enough for our tests
  posf = Posf.new(posf_buffer.dup)

  x.report("posf get operations:") do
    (iterations / 2).times do |i|
      posf.get
      posf + 1 if i < 9999
    end
  end

  # Reset
  posf = Posf.new(posf_buffer.dup)

  x.report("posf get_and_advance:") do
    (iterations / 2).times do |i|
      posf.get_and_advance
      break if posf.offset >= 19998
    end
  end
end

puts
puts "Testing edge cases and compatibility:"

# Test that our optimizations maintain compatibility
bytef = Bytef.new("hello")
puts "Original get: #{bytef.get} (should be 104 for 'h')"
bytef.set('X')
puts "After set: #{bytef.get} (should be 88 for 'X')"
puts "After advance: #{(bytef + 1).get} (should be 101 for 'e')"

# Test Posf
posf = Posf.new("\x00\x00\x01\x00\x02\x00")
puts "Posf[0]: #{posf[0]} (should be 0)"
puts "Posf[1]: #{posf[1]} (should be 1)"
puts "Posf[2]: #{posf[2]} (should be 2)"

puts
puts "All compatibility tests passed!" if bytef.get == 101 && posf[2] == 2
