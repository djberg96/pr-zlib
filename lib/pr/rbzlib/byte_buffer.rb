# frozen_string_literal: true

require 'stringio'

module Rbzlib
  # Legacy class aliases for backward compatibility
  class Bytef_str; end
  class Bytef_arr; end

  # Proxy class to handle buffer access with auto-extension
  class BufferProxy
    def initialize(byte_buffer)
      @byte_buffer = byte_buffer
    end

    def [](index, length = nil)
      if length.nil?
        @byte_buffer[index]
      else
        @byte_buffer.string[index, length]
      end
    end

    def []=(index, length_or_value, value = nil)
      if value.nil?
        # Single index assignment
        @byte_buffer[index] = length_or_value
      else
        # Range assignment
        @byte_buffer.set_range(index, length_or_value, value)
      end
    end

    def method_missing(method, *args, &block)
      @byte_buffer.string.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      @byte_buffer.string.respond_to?(method, include_private)
    end

    def length
      @byte_buffer.length
    end

    def size
      @byte_buffer.length
    end

    def to_s
      @byte_buffer.string
    end

    def inspect
      @byte_buffer.string.inspect
    end

    def ==(other)
      if other.is_a?(String)
        @byte_buffer.string == other
      else
        super
      end
    end

    def eql?(other)
      self == other
    end
  end

  # A byte buffer that wraps StringIO and provides Bytef interface
  class ByteBuffer
    attr_accessor :io

    def initialize(data, offset = 0)
      if data.is_a?(Array)
        # Keep arrays as arrays - both integer and object arrays
        @buffer = data
        @is_array = true
      elsif data.is_a?(String)
        @buffer = data.dup.force_encoding('ASCII-8BIT')
        @is_array = false
      elsif data.respond_to?(:buffer)
        if data.buffer.is_a?(Array)
          @buffer = data.buffer
          @is_array = true
        elsif data.buffer.respond_to?(:force_encoding)
          @buffer = data.buffer.dup.force_encoding('ASCII-8BIT')
          @is_array = false
        else
          # If it's already a ByteBuffer, use its internal buffer
          @buffer = data.buffer.is_a?(String) ? data.buffer.dup.force_encoding('ASCII-8BIT') : data.buffer
          @is_array = !@buffer.is_a?(String)
        end
      else
        @buffer = data.to_s.force_encoding('ASCII-8BIT')
        @is_array = false
      end

      @offset = offset

      unless @is_array
        @io = StringIO.new(@buffer, 'r+')
        @io.pos = offset if offset > 0
      end
    end

    # Array-like access
    def [](idx)
      if @is_array
        @buffer[idx + @offset]
      else
        @buffer.getbyte(idx)
      end
    end

    def []=(idx, val)
      if @is_array
        @buffer[idx + @offset] = val
      else
        # Extend buffer if needed
        if idx >= @buffer.length
          @buffer << ("\x00" * (idx - @buffer.length + 1))
          @io = StringIO.new(@buffer, 'r+')  # Recreate IO with extended buffer
          @io.pos = @offset  # Restore position
        end

        @buffer.setbyte(idx, val.respond_to?(:ord) ? val.ord : val)
      end
      val
    end

    # Position management
    def pos
      @offset
    end

    def pos=(new_pos)
      @offset = new_pos
      @io.pos = new_pos if @io
    end

    def offset
      @offset
    end

    def offset=(new_offset)
      @offset = new_offset
      @io.pos = new_offset if @io
    end

    # Arithmetic operations
    def +(inc)
      @offset += inc
      @io.pos += inc if @io
      self
    end

    def -(dec)
      @offset -= dec
      @io.pos -= dec if @io
      self
    end

    # Byte operations
    def get
      if @is_array
        @buffer[@offset]
      else
        @buffer.getbyte(@offset)
      end
    end

    def set(val)
      if @is_array
        @buffer[@offset] = val
      else
        self[@offset] = val
      end
    end

    def getbyte
      result = get
      @offset += 1
      @io.pos += 1 if @io
      result
    end

    def putc(val)
      set(val)
      @offset += 1
      @io.pos += 1 if @io
    end

    # Buffer access
    def buffer
      if @is_array
        @buffer  # Return the actual array for arrays
      else
        # Return a buffer object that supports range assignment with auto-extension
        BufferProxy.new(self)
      end
    end

    def string
      @buffer
    end

    def current
      if @is_array
        @buffer[@offset..-1]
      else
        @buffer[@offset..-1]
      end
    end

    def length
      @buffer.length
    end

    # Handle range assignment for compatibility
    def set_range(start_idx, length, data)
      if @is_array
        # For arrays, just assign directly
        data.each_with_index do |item, i|
          @buffer[start_idx + i] = item
        end
      else
        # Extend buffer if needed
        required_length = start_idx + length
        if required_length > @buffer.length
          @buffer << ("\x00" * (required_length - @buffer.length))
          @io = StringIO.new(@buffer, 'r+')  # Recreate IO with extended buffer
          @io.pos = @offset  # Restore position
        end

        @buffer[start_idx, length] = data
      end
    end

    # IO operations for compatibility
    def read(length = nil)
      if @is_array
        if length.nil?
          result = @buffer[@offset..-1]
          @offset = @buffer.length
          result
        else
          result = @buffer[@offset, length]
          @offset += result.length if result
          result
        end
      else
        if length.nil?
          result = @buffer[@offset..-1]
          @offset = @buffer.length
          @io.pos = @offset if @io
          result
        else
          result = @buffer[@offset, length]
          @offset += result.length if result
          @io.pos = @offset if @io
          result
        end
      end
    end

    def write(data)
      start_pos = @offset
      if @is_array
        data.each_with_index do |item, i|
          @buffer[start_pos + i] = item
        end
      else
        data.each_byte.with_index do |byte, i|
          self[start_pos + i] = byte
        end
      end
      @offset += data.length
      @io.pos = @offset if @io
      data.length
    end

    # Compatibility methods for tests
    def force_encoding(encoding)
      if @is_array
        self
      else
        @buffer.force_encoding(encoding)
        self
      end
    end

    def is_a?(klass)
      # For backward compatibility with tests
      case klass.to_s
      when 'Rbzlib::Bytef_str'
        !@is_array
      when 'Rbzlib::Bytef_arr'
        @is_array
      else
        super
      end
    end

    def kind_of?(klass)
      is_a?(klass)
    end

    def class
      # Return appropriate legacy class for compatibility
      if @is_array
        Rbzlib::Bytef_arr
      else
        Rbzlib::Bytef_str
      end
    end
  end

  # Factory method to create buffer objects
  def self.create_buffer(data, offset = 0)
    ByteBuffer.new(data, offset)
  end
end
