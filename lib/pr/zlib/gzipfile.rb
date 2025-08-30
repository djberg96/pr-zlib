# frozen_string_literal: true

require_relative 'zstream'
require_relative 'gzipfile_errors'

module Zlib
  class GzipFile
    GZ_MAGIC1            = 0x1f
    GZ_MAGIC2            = 0x8b
    GZ_METHOD_DEFLATE    = 8
    GZ_FLAG_MULTIPART    = 0x2
    GZ_FLAG_EXTRA        = 0x4
    GZ_FLAG_ORIG_NAME    = 0x8
    GZ_FLAG_COMMENT      = 0x10
    GZ_FLAG_ENCRYPT      = 0x20
    GZ_FLAG_UNKNOWN_MASK = 0xc0

    GZ_EXTRAFLAG_FAST    = 0x4
    GZ_EXTRAFLAG_SLOW    = 0x2

    OS_CODE = 0x03  # OS_UNIX

    GZFILE_FLAG_SYNC             = 0x10  # ZSTREAM_FLAG_UNUSED
    GZFILE_FLAG_HEADER_FINISHED  = (0x10 << 1)  # (ZSTREAM_FLAG_UNUSED << 1)
    GZFILE_FLAG_FOOTER_FINISHED  = (0x10 << 2)  # (ZSTREAM_FLAG_UNUSED << 2)

    def GZFILE_IS_FINISHED(gz)
      gz.z.ZSTREAM_IS_FINISHED() && (gz.z.buf.nil? || gz.z.buf.offset.zero?)
    end

    GZFILE_READ_SIZE = 2048

    Gzfile = Struct.new(:z, :io, :level, :mtime, :os_code, :orig_name, :comment, :crc, :lineno, :ungetc, :end)

    def gzfile_close(closeflag)
      io = @gz.io
      send(@gz.end)

      @gz.io = nil
      @gz.orig_name = nil
      @gz.comment = nil

      if closeflag && defined?(io.close)
        io.close
      end
    end

    def gzfile_ensure_close
      if @gz.z.ZSTREAM_IS_READY()
        gzfile_close(true)
      end
      nil
    end

    def self.wrap(io, level = Zlib::DEFAULT_COMPRESSION, strategy = Zlib::DEFAULT_STRATEGY)
      obj = new(io, level, strategy)
      if block_given?
        begin
          yield(obj)
        ensure
          obj.gzfile_ensure_close()
        end
      else
        obj
      end
    end

    def to_io
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.io
    end

    def crc
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.crc
    end

    def mtime
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      Time.at(@gz.mtime)
    end

    def level
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.level
    end

    def os_code
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.os_code
    end

    def orig_name
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.orig_name ? @gz.orig_name.dup : nil
    end

    def comment
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.comment ? @gz.comment.dup : nil
    end

    def close
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      gzfile_close(true)
      @gz.io
    end

    def finish
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      gzfile_close(false)
      @gz.io
    end

    def closed?
      @gz.io.nil?
    end

    def sync
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      !(@gz.z.flags & GZFILE_FLAG_SYNC).zero?
    end

    def sync=(mode)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      if mode
        @gz.z.flags |= GZFILE_FLAG_SYNC
      else
        @gz.z.flags &= ~GZFILE_FLAG_SYNC
      end
      mode
    end

    def self.gzfile_s_open(filename, mode, level, strategy, &blk)
      io = File.open(filename, mode)
      self.wrap(io, level, strategy, &blk)
    end

    private

    def gzfile_new(funcs, endfunc)
      @gz = Gzfile.new
      @gz.z = ZStream.new
      @gz.z.zstream_init(funcs)
      @gz.io = nil
      @gz.level = 0
      @gz.mtime = 0
      @gz.os_code = OS_CODE
      @gz.orig_name = nil
      @gz.comment = nil
      @gz.crc = crc32(0, nil, 0)
      @gz.lineno = 0
      @gz.ungetc = 0
      @gz.end = endfunc
      self
    end

    def gzfile_reset
      @gz.z.zstream_reset
      @gz.crc = crc32(0, nil, 0)
      @gz.lineno = 0
      @gz.ungetc = 0
    end

    def gzfile_get16(src)
      src.unpack('v').first
    end

    def gzfile_get32(src)
      src.unpack('V').first
    end

    def gzfile_set32(n)
      [n].pack('V')
    end

    def gzfile_make_header
      buf = 0.chr * 10
      flags = 0
      extraflags = 0
      if @gz.orig_name
        flags |= GZ_FLAG_ORIG_NAME
      end
      if @gz.comment
        flags |= GZ_FLAG_COMMENT
      end
      if @gz.mtime.zero?
        @gz.mtime = Time.now.to_i
      end
      if @gz.level == Zlib::BEST_SPEED
        extraflags |= GZ_EXTRAFLAG_FAST
      elsif @gz.level == Zlib::BEST_COMPRESSION
        extraflags |= GZ_EXTRAFLAG_SLOW
      end
      buf[0] = GZ_MAGIC1.chr
      buf[1] = GZ_MAGIC2.chr
      buf[2] = GZ_METHOD_DEFLATE.chr
      buf[3] = flags.chr
      buf[4, 4] = gzfile_set32(@gz.mtime)
      buf[8] = extraflags.chr
      buf[9] = @gz.os_code.chr
      @gz.z.zstream_append_buffer(buf, buf.length)

      if @gz.orig_name
        @gz.z.zstream_append_buffer(@gz.orig_name, @gz.orig_name.length)
        @gz.z.zstream_append_buffer("\0", 1)
      end
      if @gz.comment
        @gz.z.zstream_append_buffer(@gz.comment, @gz.comment.length)
        @gz.z.zstream_append_buffer("\0", 1)
      end

      @gz.z.flags |= GZFILE_FLAG_HEADER_FINISHED
    end

    def gzfile_make_footer
      buf = 0.chr * 8
      buf[0, 4] = gzfile_set32(@gz.crc)
      buf[4, 4] = gzfile_set32(@gz.z.stream.total_in)
      @gz.z.zstream_append_buffer(buf, buf.length)
      @gz.z.flags |= GZFILE_FLAG_FOOTER_FINISHED
    end

    def gzfile_read_header
      if !gzfile_read_raw_ensure(10)
        raise GzipFile::Error, 'not in gzip format'
      end

      head = @gz.z.input

      if head[0].ord != GZ_MAGIC1 || head[1].ord != GZ_MAGIC2
        raise GzipFile::Error, 'not in gzip format'
      end
      if head[2].ord != GZ_METHOD_DEFLATE
        raise GzipFile::Error, "unsupported compression method #{head[2].ord}"
      end

      flags = head[3].ord
      if (flags & GZ_FLAG_MULTIPART).nonzero?
        raise GzipFile::Error, 'multi-part gzip file is not supported'
      elsif (flags & GZ_FLAG_ENCRYPT).nonzero?
        raise GzipFile::Error, 'encrypted gzip file is not supported'
      elsif (flags & GZ_FLAG_UNKNOWN_MASK).nonzero?
        raise GzipFile::Error, 'unknown flags 0x%02x' % flags
      end

      if (head[8].ord & GZ_EXTRAFLAG_FAST).nonzero?
        @gz.level = Zlib::BEST_SPEED
      elsif (head[8].ord & GZ_EXTRAFLAG_SLOW).nonzero?
        @gz.level = Zlib::BEST_COMPRESSION
      else
        @gz.level = Zlib::DEFAULT_COMPRESSION
      end

      @gz.mtime = gzfile_get32(head[4, 4])
      @gz.os_code = head[9].ord
      @gz.z.zstream_discard_input(10)

      if (flags & GZ_FLAG_EXTRA).nonzero?
        if !gzfile_read_raw_ensure(2)
          raise GzipFile::Error, 'unexpected end of file'
        end
        len = gzfile_get16(@gz.z.input)
        if !gzfile_read_raw_ensure(2 + len)
          raise GzipFile::Error, 'unexpected end of file'
        end
        @gz.z.zstream_discard_input(2 + len)
      end
      if (flags & GZ_FLAG_ORIG_NAME).nonzero?
        ap = gzfile_read_raw_until_zero(0)
        len = ap
        @gz.orig_name = @gz.z.input[0, len]
        @gz.z.zstream_discard_input(len + 1)
      end
      if (flags & GZ_FLAG_COMMENT).nonzero?
        ap = gzfile_read_raw_until_zero(0)
        len = ap
        @gz.comment = @gz.z.input[0, len]
        @gz.z.zstream_discard_input(len + 1)
      end

      if @gz.z.input && @gz.z.input.length > 0
        @gz.z.zstream_run(0, 0, Zlib::SYNC_FLUSH)
      end
    end

    def gzfile_check_footer
      @gz.z.flags |= GZFILE_FLAG_FOOTER_FINISHED

      if !gzfile_read_raw_ensure(8)
        raise NoFooter, 'footer is not found'
      end
      crc = gzfile_get32(@gz.z.input)
      length = gzfile_get32(@gz.z.input[4, 4])
      @gz.z.stream.total_in += 8
      @gz.z.zstream_discard_input(8)
      if @gz.crc != crc
        raise CRCError, 'invalid compressed data -- crc error'
      end
      if @gz.z.stream.total_out != length
        raise LengthError, 'invalid compressed data -- length error'
      end
    end

    def gzfile_calc_crc(str)
      if str.length <= @gz.ungetc
        @gz.ungetc -= str.length
      else
        @gz.crc = crc32(@gz.crc, str[@gz.ungetc, str.length - @gz.ungetc],
         str.length - @gz.ungetc)
        @gz.ungetc = 0
      end
    end
  end
end
