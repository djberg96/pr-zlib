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

    # Direct delegation for performance-critical methods
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

    def force_encoding(encoding)
      @byte_buffer.string.force_encoding(encoding)
      self
    end

    def getbyte(index)
      @byte_buffer.string.getbyte(index)
    end

    def setbyte(index, value)
      @byte_buffer.string.setbyte(index, value)
    end

    # Only use method_missing for non-performance-critical methods
    def method_missing(method, *args, &block)
      @byte_buffer.string.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      @byte_buffer.string.respond_to?(method, include_private)
    end
  end

  # A byte buffer that provides Bytef interface with minimal overhead
  class ByteBuffer
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
        elsif data.buffer.is_a?(BufferProxy)
          # Extract underlying string from BufferProxy
          @buffer = data.buffer.to_s.dup.force_encoding('ASCII-8BIT')
          @is_array = false
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
        # Extend buffer if needed - do this efficiently
        if idx >= @buffer.length
          @buffer << ("\x00" * (idx - @buffer.length + 1))
        end

        @buffer.setbyte(idx, val.respond_to?(:ord) ? val.ord : val)
      end
      val
    end

    # Position management - no StringIO overhead
    def pos
      @offset
    end

    def pos=(new_pos)
      @offset = new_pos
    end

    def offset
      @offset
    end

    def offset=(new_offset)
      @offset = new_offset
    end

    # Arithmetic operations
    def +(inc)
      @offset += inc
      self
    end

    def -(dec)
      @offset -= dec
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
      result
    end

    def putc(val)
      set(val)
      @offset += 1
    end

    # Buffer access

    def buffer=(new_buffer)
      if new_buffer.is_a?(BufferProxy)
        # Extract the underlying buffer from BufferProxy
        @buffer = new_buffer.to_s.dup.force_encoding('ASCII-8BIT')
        @is_array = false
      elsif new_buffer.is_a?(Array)
        @buffer = new_buffer.dup
        @is_array = true
      elsif new_buffer.is_a?(String)
        @buffer = new_buffer.dup.force_encoding('ASCII-8BIT')
        @is_array = false
      elsif new_buffer.respond_to?(:buffer)
        # Handle ByteBuffer objects
        if new_buffer.buffer.is_a?(Array)
          @buffer = new_buffer.buffer.dup
          @is_array = true
        else
          @buffer = new_buffer.string.dup.force_encoding('ASCII-8BIT')
          @is_array = false
        end
      else
        @buffer = new_buffer.to_s.force_encoding('ASCII-8BIT')
        @is_array = false
      end
      @offset = 0  # Reset offset when buffer is replaced
    end

    def string
      @buffer
    end

    def current
      if @offset > @buffer.length
        return @buffer.class.new
      end

      if @buffer.is_a?(String)
        @buffer[@offset..-1]
      elsif @buffer.is_a?(Array)
        @buffer[@offset..-1]
      else
        raise "ERROR: @buffer is #{@buffer.class}, expected String or Array. Value type: #{@buffer.class}"
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
          result
        else
          result = @buffer[@offset, length]
          @offset += result.length if result
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

    # Setter for buffer property - extracts underlying data from wrappers
    def buffer=(value)
      if value.is_a?(BufferProxy)
        @buffer = value.instance_variable_get(:@byte_buffer).instance_variable_get(:@buffer)
      elsif value.is_a?(ByteBuffer)
        @buffer = value.instance_variable_get(:@buffer)
      elsif value.is_a?(String) || value.is_a?(Array)
        @buffer = value
      else
        raise "Cannot assign buffer of type #{value.class}"
      end
    end

    # Getter for buffer property
    def buffer
      if @is_array
        @buffer  # Return the actual array for arrays
      else
        # Return a buffer object that supports range assignment with auto-extension
        BufferProxy.new(self)
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
