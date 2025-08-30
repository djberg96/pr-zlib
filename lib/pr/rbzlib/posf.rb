# frozen_string_literal: true

require_relative 'bytef_str'

module Rbzlib
  class Posf < Bytef_str
    def +(inc)
      @offset += inc * 2
      self
    end

    def -(dec)
      @offset -= dec * 2
      self
    end

    def [](idx)
      @buffer[(idx * 2) + @offset, 2].unpack('v').first
    end

    def []=(idx, val)
      @buffer[(idx * 2) + @offset, 2] = [val].pack('v')
    end

    def get
      @buffer[@offset, 2].unpack('v').first
    end

    def set(val)
      @buffer[@offset, 2] = [val].pack('v')
    end
  end
end
