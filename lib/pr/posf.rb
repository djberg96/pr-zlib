require_relative 'bytef_str'

module Rbzlib
  class Posf < Bytef_str
    ELEMENT_SIZE = 2

    def +(inc)
      @offset += inc * ELEMENT_SIZE
      self
    end

    def -(dec)
      @offset -= dec * ELEMENT_SIZE
      self
    end

    def [](idx)
      pos = (idx * ELEMENT_SIZE) + @offset
      return 0 if pos >= @buffer.bytesize - 1

      @buffer.unpack1('v', offset: pos)
    end

    def []=(idx, val)
      pos = (idx * ELEMENT_SIZE) + @offset
      return if pos >= @buffer.bytesize - 1

      # Ensure buffer is large enough
      if pos + ELEMENT_SIZE > @buffer.bytesize
        @buffer << "\0" * (pos + ELEMENT_SIZE - @buffer.bytesize)
      end

      # Pack directly into buffer at position
      @buffer[pos, ELEMENT_SIZE] = [val].pack('v')
    end

    def get
      return 0 if @offset >= @buffer.bytesize - 1

      @buffer.unpack1('v', offset: @offset)
    end

    def set(val)
      return if @offset >= @buffer.bytesize - 1

      # Ensure buffer is large enough
      if @offset + ELEMENT_SIZE > @buffer.bytesize
        @buffer << "\0" * (@offset + ELEMENT_SIZE - @buffer.bytesize)
      end

      @buffer[@offset, ELEMENT_SIZE] = [val].pack('v')
    end

    # Additional utility methods for 16-bit operations
    def length_in_elements
      @buffer.bytesize / ELEMENT_SIZE
    end

    def peek_element(offset_elements = 0)
      pos = @offset + (offset_elements * ELEMENT_SIZE)
      return 0 if pos >= @buffer.bytesize - 1

      @buffer.unpack1('v', offset: pos)
    end

    def advance_elements(count = 1)
      @offset = [@offset + (count * ELEMENT_SIZE), @buffer.bytesize].min
      self
    end

    def rewind_elements(count = 1)
      @offset = [@offset - (count * ELEMENT_SIZE), 0].max
      self
    end

    def remaining_elements
      [(@buffer.bytesize - @offset) / ELEMENT_SIZE, 0].max
    end

    def current_element_index
      @offset / ELEMENT_SIZE
    end

    def to_array
      return [] if @buffer.bytesize < ELEMENT_SIZE

      start_pos = @offset
      element_count = (@buffer.bytesize - start_pos) / ELEMENT_SIZE
      return [] if element_count <= 0

      @buffer.unpack("v#{element_count}", offset: start_pos)
    end

    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} @buffer.bytesize=#{@buffer.bytesize} @offset=#{@offset} current_element=#{get}>"
    end
  end
end
