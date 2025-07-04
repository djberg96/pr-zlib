module Rbzlib
  class Bytef_str
    attr_accessor :buffer, :offset

    def initialize(buffer, offset = 0)
      case buffer
      when String
        @buffer = buffer.dup.force_encoding('ASCII-8BIT')
        @offset = offset
      when Bytef_str
        @buffer = buffer.buffer
        @offset = offset
      else
        @buffer = buffer.buffer
        @offset = offset
      end
    end

    def length
      @buffer.bytesize
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
      byte_value = val.respond_to?(:ord) ? val.ord : val.to_i
      @buffer.setbyte(idx + @offset, byte_value)
    end

    def get
      @buffer.getbyte(@offset)
    end

    def set(val)
      byte_value = val.respond_to?(:ord) ? val.ord : val.to_i
      @buffer.setbyte(@offset, byte_value)
    end

    def current
      @offset >= @buffer.bytesize ? '' : @buffer[@offset..-1]
    end

    # Additional optimizations
    def slice(start_idx, length = nil)
      start_pos = start_idx + @offset
      return '' if start_pos >= @buffer.bytesize

      if length
        @buffer[start_pos, length] || ''
      else
        @buffer[start_pos..-1] || ''
      end
    end

    def peek(count = 1)
      return '' if @offset >= @buffer.bytesize

      end_pos = [@offset + count, @buffer.bytesize].min
      @buffer[@offset, end_pos - @offset]
    end

    def advance(count = 1)
      @offset = [@offset + count, @buffer.bytesize].min
      self
    end

    def rewind(count = 1)
      @offset = [@offset - count, 0].max
      self
    end

    def at_end?
      @offset >= @buffer.bytesize
    end

    def remaining
      [@buffer.bytesize - @offset, 0].max
    end

    def to_s
      current
    end

    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} @buffer=#{@buffer.inspect} @offset=#{@offset}>"
    end
  end
end
