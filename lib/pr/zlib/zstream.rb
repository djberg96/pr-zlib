# frozen_string_literal: true

require_relative 'errors'

module Zlib
  class ZStream
    attr_accessor :flags, :buf, :input, :stream, :func

    def raise_zlib_error(err, msg)
      msg = zError(err) if msg.nil? || msg == ''

      case err
        when Z_STREAM_END
          raise StreamEnd, msg
        when Z_NEED_DICT
          raise NeedDict, msg
        when Z_STREAM_ERROR
          raise StreamError, msg
        when Z_DATA_ERROR
          raise DataError, msg
        when Z_BUF_ERROR
          raise BufError, msg
        when Z_VERSION_ERROR
          raise VersionError, msg
        when Z_MEM_ERROR
          raise MemError, msg
        when Z_ERRNO
          raise SystemCallError, msg
        else
          raise Error, 'unknown zlib error #errend: #msgend'
      end
    end

    def zstream_expand_buffer
      if @buf.nil?
        @buf = Bytef.new(0.chr * ZSTREAM_INITIAL_BUFSIZE)
        @stream.next_out = Bytef.new(@buf)
        @stream.avail_out = ZSTREAM_INITIAL_BUFSIZE
        return
      end

      if @buf.length - @buf.offset >= ZSTREAM_AVAIL_OUT_STEP_MAX
        @stream.avail_out = ZSTREAM_AVAIL_OUT_STEP_MAX
      else
        inc = @buf.offset / 2
        if inc < ZSTREAM_AVAIL_OUT_STEP_MIN
          inc = ZSTREAM_AVAIL_OUT_STEP_MIN
        end
        if @buf.length < @buf.offset + inc
          @buf.buffer << 0.chr * (@buf.offset + inc - @buf.length)
        end
        @stream.avail_out = (inc < ZSTREAM_AVAIL_OUT_STEP_MAX) ?
            inc : ZSTREAM_AVAIL_OUT_STEP_MAX
      end
      @stream.next_out = Bytef.new(@buf, @buf.offset)
    end

    def zstream_append_buffer(src, len)
      if @buf.nil?
        @buf = Bytef.new(src[0, len], len)
        @stream.next_out = Bytef.new(@buf)
        @stream.avail_out = 0
        return
      end
      if @buf.length < @buf.offset + len
        @buf.buffer << (0.chr * (@buf.offset + len - @buf.length))
        @stream.avail_out = 0
      else
        if @stream.avail_out >= len
          @stream.avail_out -= len
        else
          @stream.avail_out = 0
        end
      end
      @buf.buffer[@buf.offset, len] = src[0, len]
      @buf += len
      @stream.next_out = Bytef.new(@buf, @buf.offset)
    end

    def zstream_detach_buffer
      if @buf.nil?
        dst = ''
      else
        dst = @buf.buffer[0, @buf.offset]
      end

      @buf = Bytef.new(0.chr * ZSTREAM_INITIAL_BUFSIZE)
      @stream.next_out = Bytef.new(@buf)
      @stream.avail_out = ZSTREAM_INITIAL_BUFSIZE
      @buf_filled = 0

      dst
    end

    def zstream_shift_buffer(len)
      if @buf.offset <= len
        return zstream_detach_buffer()
      end

      dst = @buf.buffer[0, len]
      @buf -= len
      @buf.buffer[0, @buf.offset] = @buf.buffer[len, @buf.offset]
      @stream.next_out = Bytef.new(@buf, @buf.offset)
      @stream.avail_out = @buf.length - @buf.offset
      if @stream.avail_out > ZSTREAM_AVAIL_OUT_STEP_MAX
        @stream.avail_out = ZSTREAM_AVAIL_OUT_STEP_MAX
      end
      dst
    end

    def zstream_buffer_ungetc(c)
      if @buf.nil? || (@buf.length - @buf.offset).zero?
        zstream_expand_buffer()
      end
      @buf.buffer[0, 0] = c.chr
      @buf += 1
      if @stream.avail_out > 0
        @stream.next_out += 1
        @stream.avail_out -= 1
      end
    end

    def zstream_append_input(src, len)
      return if len <= 0
      src = src.current if src.class != String
      if @input.nil?
        @input = src[0, len]
      else
        @input << src[0, len]
      end
    end

    def zstream_discard_input(len)
      if @input.nil? || @input.length <= len
        @input = nil
      else
        @input[0, len] = ''
      end
    end

    def zstream_reset_input
      @input = nil
    end

    def zstream_passthrough_input
      if @input
        zstream_append_buffer(@input, @input.length)
        @input = nil
      end
    end

    def zstream_detach_input
      if @input.nil?
        dst = ''
      else
        dst = @input
      end
      @input = nil
      dst
    end

    def zstream_reset
      err = send(@func.reset, @stream)
      if err != Z_OK
        raise_zlib_error(err, @stream.msg)
      end
      @flags = ZSTREAM_FLAG_READY
      @buf = nil
      @buf_filled = 0
      @stream.next_out = 0
      @stream.avail_out = 0
      zstream_reset_input()
    end

    def zstream_end
      if !ZSTREAM_IS_READY()
        warn('attempt to close uninitialized zstream; ignored.')
        return nil
      end
      if (@flags & ZSTREAM_FLAG_IN_STREAM).nonzero?
        warn('attempt to close unfinished zstream; reset forced.')
        zstream_reset()
      end

      zstream_reset_input()
      err = send(@func.end, @stream)
      if err != Z_OK
        raise_zlib_error(err, @stream.msg)
      end
      @flags = 0
      nil
    end

    def zstream_sync(src, len)
      if @input
        @stream.next_in = Bytef.new(@input)
        @stream.avail_in = @input.length
        err = inflateSync(@stream)
        if err == Z_OK
          zstream_discard_input(@input.length - @stream.avail_in)
          zstream_append_input(src, len)
          return true
        end
        zstream_reset_input()
        if err != Z_DATA_ERROR
          @stream.next_in.buffer[0, @stream.avail_in]
          raise_zlib_error(err, @stream.msg)
        end
      end

      return false if len <= 0

      @stream.next_in = src
      @stream.avail_in = len
      err = inflateSync(@stream)
      if err == Z_OK
        zstream_append_input(@stream.next_in, @stream.avail_in)
        return true
      end
      if err != Z_DATA_ERROR
        @stream.next_in.buffer[0, @stream.avail_in]
        raise_zlib_error(err, @stream.msg)
      end
      false
    end

    def zstream_init(func)
      @flags = 0
      @buf = nil
      @input = nil
      @stream = Z_stream.new
      @stream.msg = ''
      @stream.next_in = nil
      @stream.avail_in = 0
      @stream.next_out = nil
      @stream.avail_out = 0
      @func = func
    end

    def zstream_run(src, len, flush)
      if @input.nil? && len == 0
        @stream.next_in = ''
        @stream.avail_in = 0
      else
        zstream_append_input(src, len)
        @stream.next_in = Bytef.new(@input)
        @stream.avail_in = @input.length
      end
      if @stream.avail_out.zero?
        zstream_expand_buffer()
      end

      loop do
        n = @stream.avail_out
        err = send(@func.run, @stream, flush)
        @buf += n - @stream.avail_out
        if err == Z_STREAM_END
          @flags &= ~ZSTREAM_FLAG_IN_STREAM
          @flags |= ZSTREAM_FLAG_FINISHED
          break
        end
        if err != Z_OK
          if flush != Z_FINISH && err == Z_BUF_ERROR && @stream.avail_out > 0
            @flags |= ZSTREAM_FLAG_IN_STREAM
            break
          end
          @input = nil
          if @stream.avail_in > 0
            zstream_append_input(@stream.next_in, @stream.avail_in)
          end
          raise_zlib_error(err, @stream.msg)
        end
        if @stream.avail_out > 0
          @flags |= ZSTREAM_FLAG_IN_STREAM
          break
        end
        zstream_expand_buffer()
      end

      @input = nil
      if @stream.avail_in > 0
        zstream_append_input(@stream.next_in, @stream.avail_in)
      end
    end

    def ZSTREAM_READY
      (@flags |= ZSTREAM_FLAG_READY)
    end

    def ZSTREAM_IS_READY
      !(@flags & ZSTREAM_FLAG_READY).zero?
    end

    def ZSTREAM_IS_FINISHED
      !(@flags & ZSTREAM_FLAG_FINISHED).zero?
    end

    def ZSTREAM_IS_CLOSING
      !(@flags & ZSTREAM_FLAG_CLOSING).zero?
    end
  end

    @@final = proc do |z|
      proc do
        if z && z.ZSTREAM_IS_READY()
          err = send(z.func.end, z.stream)
          if err == Z_STREAM_ERROR
            warn('the stream state was inconsistent.')
          end
          if err == Z_DATA_ERROR
            warn('the stream was freed prematurely.')
          end
        end
      end
    end

    attr_reader :z

    def avail_out
      @z.stream.avail_out
    end

    def avail_out=(size)
      if @z.buf.nil?
        @z.buf = Bytef.new(0.chr * size)
        @z.stream.next_out = Bytef.new(@z.buf)
        @z.stream.avail_out = size
      elsif @z.stream.avail_out != size
        if @z.buf.offset + size > @z.buf.length
          @z.buf.buffer << 0.chr * (@z.buf.offset + size - @z.buf.length)
        end
        @z.stream.next_out = Bytef.new(@z.buf, @z.buf.offset)
        @z.stream.avail_out = size
      end
    end

    def avail_in
      @z.input.nil? ? 0 : @z.input.length
    end

    def total_in
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @z.stream.total_in
    end

    def total_out
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @z.stream.total_out
    end

    def data_type
      @z.stream.data_type
    end

    def adler
      @z.stream.adler
    end

    def finished?
      @z.ZSTREAM_IS_FINISHED()
    end
    alias stream_end? :finished?

    def closed?
      @z.ZSTREAM_IS_READY()
    end
    alias ended? :closed?

    def close
      if !@z.ZSTREAM_IS_READY()
        warn('attempt to close uninitialized zstream ignored.')
        return nil
      end
      if (@z.flags & ZSTREAM_FLAG_IN_STREAM).nonzero?
        warn('attempt to close unfinished zstream reset forced.')
        @z.input = nil
      end

      @z.input = nil
      err = send(@z.func.end, @z.stream)
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end
      @z.flags = 0
    end
    alias end :close

    def reset
      err = send(@z.func.reset, @z.stream)
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end
      @z.flags = ZSTREAM_FLAG_READY
      @z.buf = nil
      @z.stream.next_out = 0
      @z.stream.avail_out = 0
      @z.input = nil
    end

    def finish
      @z.zstream_run('', 0, Z_FINISH)
      @z.zstream_detach_buffer()
    end

    def flush_next_in
      @z.zstream_detach_input
    end

    def flush_next_out
      @z.zstream_detach_buffer
    end

    def initialize
      @z = nil
      ObjectSpace.define_finalizer self, @@final.call(@z)
    end
end
