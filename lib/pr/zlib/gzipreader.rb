# frozen_string_literal: true

require_relative 'gzipfile'

module Zlib
  class GzipReader < GzipFile
    include Enumerable

    def lineno
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.lineno
    end

    def lineno=(lineno)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.lineno = lineno
    end

    def eof
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      GZFILE_IS_FINISHED(@gz)
    end
    alias eof? :eof

    def pos
      if @gz.z.buf.nil?
        @gz.z.stream.total_out
      else
        @gz.z.stream.total_out - @gz.z.buf.offset
      end
    end
    alias tell :pos

    def self.open(filename, level = Z_DEFAULT_COMPRESSION, strategy = Z_DEFAULT_STRATEGY, &blk)
      GzipReader.gzfile_s_open(filename, 'rb', level, strategy, &blk)
    end

    def initialize(io, level = Z_DEFAULT_COMPRESSION, _strategy = Z_DEFAULT_STRATEGY)
      gzfile_new(InflateFuncs, :gzfile_reader_end)
      @gz.level = level
      err = inflateInit2(@gz.z.stream, -MAX_WBITS)
      if err != Z_OK
        raise_zlib_error(err, @gz.stream.msg)
      end
      @gz.io = io
      @gz.z.ZSTREAM_READY()
      gzfile_read_header()
      self
    end

    def rewind
      gzfile_reader_rewind()
      0
    end

    def unused
      gzfile_reader_get_unused()
    end

    def read(len = nil)
      if len.nil?
        return gzfile_read_all()
      end

      if len < 0
        raise ArgumentError, "negative length #{len} given"
      end

      gzfile_read(len)
    end

    def getc
      dst = gzfile_read(1)
      dst ? dst[0] : dst
    end

    def readchar
      dst = getc()
      if dst.nil?
        raise EOFError, 'end of file reached'
      end
      dst
    end

    def each_byte
      while (c = getc)
        yield(c)
      end
      nil
    end

    def ungetc(ch)
      gzfile_ungetc(ch)
      nil
    end

    def gets(rs = $INPUT_RECORD_SEPARATOR)
      dst = gzreader_gets(rs)
      $_ = dst if dst
      dst
    end

    def readline(rs = $INPUT_RECORD_SEPARATOR)
      gets(rs)
    end

    def each(rs = $INPUT_RECORD_SEPARATOR)
      while (str = gzreader_gets(rs))
        yield(str)
      end
      self
    end
    alias each_line :each

    def readlines(rs = $INPUT_RECORD_SEPARATOR)
      dst = []
      while str = gzreader_gets(rs)
        dst.push(str)
      end
      dst
    end

    private

    def gzfile_reader_end_run
      if GZFILE_IS_FINISHED(@gz) && (@gz.z.flags &
        GZFILE_FLAG_FOOTER_FINISHED).zero?
        gzfile_check_footer()
      end
      nil
    end

    def gzfile_reader_end
      return if @gz.z.ZSTREAM_IS_CLOSING()
      @gz.z.flags |= ZSTREAM_FLAG_CLOSING
      begin
        gzfile_reader_end_run()
      ensure
        @gz.z.zstream_end()
      end
    end

    def gzfile_ungetc(c)
      @gz.z.zstream_buffer_ungetc(c)
      @gz.ungetc += 1
    end

    def gzfile_reader_rewind
      n = @gz.z.stream.total_in
      if @gz.z.input
        n += @gz.z.input.length
      end
      @gz.io.seek(-n, 1)
      gzfile_reset()
    end

    def gzfile_reader_get_unused
      return nil if !@gz.z.ZSTREAM_IS_READY()
      return nil if !GZFILE_IS_FINISHED(@gz)
      if (@gz.z.flags & GZFILE_FLAG_FOOTER_FINISHED).zero?
        gzfile_check_footer()
      end
      return nil if @gz.z.input.nil?
      @gz.z.input.dup
    end

    def rscheck(rsptr, _rslen, rs)
      raise RuntimeError, 'rs modified' if rs != rsptr
    end

    def gzreader_skip_linebreaks
      # Skip consecutive newline characters for paragraph mode
      while (c = getc)
        case c
        when "\n", "\r"
          # Continue skipping
        else
          ungetc(c)
          break
        end
      end
    end

    def gzreader_gets(rs = $INPUT_RECORD_SEPARATOR)
      if rs && rs.class != String
        raise TypeError, "wrong argument type #{rs.class} (expected String)"
      end
      if rs.nil?
        dst = gzfile_read_all()
        @gz.lineno += 1 if dst.length.nonzero?
        return dst
      end
      if rs.length.zero?
        rsptr = "\n\n"
        rslen = 2
        rspara = true
      else
        rsptr = rs
        rslen = rs.length
        rspara = false
      end
      if rspara
        gzreader_skip_linebreaks
      end
      while @gz.z.buf.offset < rslen
        if @gz.z.ZSTREAM_IS_FINISHED()
          @gz.lineno += 1 if @gz.z.buf.offset > 0
          return gzfile_read(rslen)
        end
        gzfile_read_more()
      end

      ap = 0
      n = rslen
      loop do
        if n > @gz.z.buf.offset
          break if @gz.z.ZSTREAM_IS_FINISHED()
          gzfile_read_more()
          ap = n - rslen
        end

        rscheck(rsptr, rslen, rs) if !rspara
        res = @gz.z.buf.buffer[ap, @gz.z.buf.offset - n + 1].index(rsptr[0])

        if res.nil?
          n = @gz.z.buf.offset + 1
        else
          n += (res - ap)
          ap = res
          break if rslen == 1 || @gz.z.buf.buffer[ap, rslen] == rsptr
          ap += 1
          n += 1
        end
      end

      @gz.lineno += 1
      dst = gzfile_read(n)
      if rspara
        gzreader_skip_linebreaks()
      end
      dst
    end

    def gzfile_read(len)
      if len < 0
        raise ArgumentError, "negative length #{len} given"
      end

      if len.zero?
        return ''
      end

      if @gz.z.buf.nil?
        @gz.z.buf = Bytef.new(0.chr * len)
      end

      while !@gz.z.ZSTREAM_IS_FINISHED() && @gz.z.buf.offset < len
        gzfile_read_more()
      end

      if GZFILE_IS_FINISHED(@gz)
        if (@gz.z.flags & GZFILE_FLAG_FOOTER_FINISHED).zero?
          gzfile_check_footer()
        end
        return nil
      end

      dst = @gz.z.zstream_shift_buffer(len)
      gzfile_calc_crc(dst)
      dst
    end

    def gzfile_read_all
      while !@gz.z.ZSTREAM_IS_FINISHED()
        gzfile_read_more()
      end
      if GZFILE_IS_FINISHED(@gz)
        if (@gz.z.flags & GZFILE_FLAG_FOOTER_FINISHED).zero?
          gzfile_check_footer()
        end
        return ''
      end

      dst = @gz.z.zstream_detach_buffer()
      gzfile_calc_crc(dst)
      dst
    end

    def gzfile_read_raw
      str = @gz.io.read(GZFILE_READ_SIZE)
      if str && str.class != String
        raise TypeError, "wrong argument type #{rs.class} (expected String)"
      end
      str
    end

    def gzfile_read_raw_ensure(size)
      while @gz.z.input.nil? || @gz.z.input.length < size
        str = gzfile_read_raw()
        return false if str.nil?
        @gz.z.zstream_append_input(str, str.length)
      end
      true
    end

    def gzfile_read_raw_until_zero(offset)
      ap = nil

      loop do
        ap = @gz.z.input[offset, @gz.z.input.length - offset].index(0.chr)
        break if ap
        str = gzfile_read_raw()

        raise Error, 'unexpected end of file' if str.nil?

        offset = @gz.z.input.length
        @gz.z.zstream_append_input(str, str.length)
      end

      ap
    end

    def gzfile_read_more
      while !@gz.z.ZSTREAM_IS_FINISHED()
        str = gzfile_read_raw()
        if str.nil?
          if !@gz.z.ZSTREAM_IS_FINISHED()
            raise Error, 'unexpected end of file'
          end
          break
        end
        if str.length > 0
          @gz.z.zstream_run(str, str.length, Z_SYNC_FLUSH)
        end
        break if @gz.z.buf.offset > 0
      end
      @gz.z.buf.offset
    end
  end
end
