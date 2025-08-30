# frozen_string_literal: true

module Rbzlib
  class Bytef_str
    attr_accessor :buffer, :offset

    def initialize(buffer, offset = 0)
      if buffer.class == String
        @buffer = buffer
        @offset = offset
        @buffer.force_encoding('ASCII-8BIT')
      else
        @buffer = buffer.buffer
        @offset = offset
      end
    end

    def length
      @buffer.length
    end

    def +(inc)
      # Optimize: avoid method call overhead and use direct assignment
      @offset += inc
      self
    end

    def -(dec)
      # Optimize: avoid method call overhead and use direct assignment
      @offset -= dec
      self
    end

    def [](idx)
      @buffer.getbyte(idx + @offset)
    end

    def []=(idx, val)
      @buffer.setbyte(idx + @offset, val.is_a?(String) ? val.ord : val)
    end

    def get
      # Optimize: direct byte access without intermediate calculations
      @buffer.getbyte(@offset)
    end

    def set(val)
      @buffer.setbyte(@offset, val.is_a?(String) ? val.ord : val)
    end

    def current
      @buffer[@offset..-1]
    end

    # Optimized bulk operations to reduce method call overhead
    def advance(count)
      @offset += count
      self
    end

    def retreat(count)
      @offset -= count
      self
    end

    def get_and_advance
      val = @buffer.getbyte(@offset)
      @offset += 1
      val
    end

    def set_and_advance(val)
      @buffer.setbyte(@offset, val.is_a?(String) ? val.ord : val)
      @offset += 1
      self
    end
  end
end
