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
      # Optimize: cache offset calculation and use more efficient unpacking
      offset_pos = (idx * 2) + @offset
      @buffer[offset_pos, 2].unpack1('v')
    end

    def []=(idx, val)
      # Optimize: cache offset calculation
      offset_pos = (idx * 2) + @offset
      @buffer[offset_pos, 2] = [val].pack('v')
    end

    def get
      # Optimize: use unpack1 for single value
      @buffer[@offset, 2].unpack1('v')
    end

    def set(val)
      @buffer[@offset, 2] = [val].pack('v')
    end

    # Optimized bulk operations
    def get_and_advance
      val = @buffer[@offset, 2].unpack1('v')
      @offset += 2
      val
    end

    def set_and_advance(val)
      @buffer[@offset, 2] = [val].pack('v')
      @offset += 2
      self
    end
  end
end
