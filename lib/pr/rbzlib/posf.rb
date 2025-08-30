# frozen_string_literal: true

require_relative 'byte_buffer'

module Rbzlib
  class Posf < ByteBuffer
    def +(inc)
      @offset += inc * 2
      @io.pos = @offset if @io && @offset >= 0
      self
    end

    def -(dec)
      @offset -= dec * 2
      @io.pos = @offset if @io && @offset >= 0
      self
    end

    def [](idx)
      if @is_array
        # For arrays, manually calculate 16-bit little-endian value
        pos = (idx * 2) + @offset
        @buffer[pos] + (@buffer[pos + 1] << 8)
      else
        @buffer[(idx * 2) + @offset, 2].unpack('v').first
      end
    end

    def []=(idx, val)
      if @is_array
        # For arrays, manually set 16-bit little-endian value
        pos = (idx * 2) + @offset
        @buffer[pos] = val & 0xff
        @buffer[pos + 1] = (val >> 8) & 0xff
      else
        @buffer[(idx * 2) + @offset, 2] = [val].pack('v')
      end
    end

    def get
      if @is_array
        @buffer[@offset] + (@buffer[@offset + 1] << 8)
      else
        @buffer[@offset, 2].unpack('v').first
      end
    end

    def set(val)
      if @is_array
        @buffer[@offset] = val & 0xff
        @buffer[@offset + 1] = (val >> 8) & 0xff
      else
        @buffer[@offset, 2] = [val].pack('v')
      end
    end
  end
end
