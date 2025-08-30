# frozen_string_literal: true

require_relative 'bytef_str'

module Rbzlib
  class Bytef_arr < Bytef_str

    def initialize(buffer, offset = 0)
      @buffer = buffer
      @offset = offset
    end

    def [](idx)
      @buffer[idx + @offset]
    end

    def []=(idx, val)
      @buffer[idx + @offset] = val
    end

    def get
      @buffer[@offset]
    end

    def set(val)
      @buffer[@offset] = val
    end
  end
end
