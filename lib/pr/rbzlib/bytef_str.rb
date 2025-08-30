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
      @offset += inc
      self
    end

    def -(dec)
      @offset -= dec
      self
    end

    def [](idx)
      @buffer.getbyte(idx + @offset)
    end

    def []=(idx, val)
      @buffer.setbyte(idx + @offset, val.ord)
    end

    def get
      @buffer.getbyte(@offset)
    end

    def set(val)
      @buffer.setbyte(@offset, val.ord)
    end

    def current
      @buffer[@offset..-1]
    end
  end
end
