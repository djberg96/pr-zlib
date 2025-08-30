# frozen_string_literal: true

require_relative 'gzipfile'

module Zlib
  class GzipWriter < GzipFile

    def mtime=(mtime)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()

      if (@gz.z.flags & GZFILE_FLAG_HEADER_FINISHED).nonzero?
        raise GzipFile::Error, 'header is already written'
      end

      @gz.mtime = mtime.to_i
    end

    def orig_name=(str)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()

      if (@gz.z.flags & GZFILE_FLAG_HEADER_FINISHED).nonzero?
        raise GzipFile::Error, 'header is already written'
      end

      ap = str[0.chr]
      @gz.orig_name = ap ? str[0, ap] : str.dup
    end

    def comment=(str)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()

      if (@gz.z.flags & GZFILE_FLAG_HEADER_FINISHED).nonzero?
        raise GzipFile::Error, 'header is already written'
      end

      @gz.comment = str.dup
    end

    def pos
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @gz.z.stream.total_in
    end

    alias tell :pos

    def self.open(filename, level = Z_DEFAULT_COMPRESSION, strategy = Z_DEFAULT_STRATEGY, &blk)
      GzipWriter.gzfile_s_open(filename, 'wb', level, strategy, &blk)
    end

    def initialize(io, level = nil, strategy = nil)
      level = Z_DEFAULT_COMPRESSION if level.nil?
      strategy = Z_DEFAULT_STRATEGY if strategy.nil?

      gzfile_new(DeflateFuncs, :gzfile_writer_end)
      @gz.level = level

      err = deflateInit2(
         @gz.z.stream,
         @gz.level,
         Z_DEFLATED,
         -MAX_WBITS,
         DEF_MEM_LEVEL,
         strategy
      )

      if err != Z_OK
        raise_zlib_error(err, @gz.stream.msg)
      end

      @gz.io = io
      @gz.z.ZSTREAM_READY()
    end

    def flush(v_flush = Z_SYNC_FLUSH)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()

      if v_flush != Z_NO_FLUSH
        @gz.z.zstream_run('', 0, v_flush)
      end

      gzfile_write_raw()

      if defined?(@gz.io.flush)
        @gz.io.flush()
      end

      self
    end

    def write(str)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      str = str.to_s
      gzfile_write(str, str.length)
      str.length
    end

    def putc(ch)
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      gzfile_write(ch.chr, 1)
      ch
    end

    def <<(str)
      @gz.io << str
    end

    def printf(*arg)
      @gz.io.printf(*arg)
    end

    def print(*arg)
      @gz.io.print(*arg)
    end

    def puts(str)
      @gz.io.puts(str)
    end

    def gzfile_write_raw
      if @gz.z.buf.offset > 0
        str = @gz.z.zstream_detach_buffer()
        @gz.io.write(str)
        if (@gz.z.flags & GZFILE_FLAG_SYNC).nonzero? && defined?(@gz.io.flush)
          @gz.io.flush()
        end
      end
    end

    private :gzfile_write_raw

    def gzfile_write(str, len)
      if (@gz.z.flags & GZFILE_FLAG_HEADER_FINISHED).zero?
        gzfile_make_header()
      end

      if len > 0 || (@gz.z.flags & GZFILE_FLAG_SYNC)
        @gz.crc = crc32(@gz.crc, str, len)
        @gz.z.zstream_run(str, len, (@gz.z.flags & GZFILE_FLAG_SYNC).nonzero? ?
            Z_SYNC_FLUSH : Z_NO_FLUSH)
      end
      gzfile_write_raw()
    end

    private :gzfile_write

    def gzfile_writer_end_run
      if (@gz.z.flags & GZFILE_FLAG_HEADER_FINISHED).zero?
        gzfile_make_header()
      end
      @gz.z.zstream_run('', 0, Z_FINISH)
      gzfile_make_footer()
      gzfile_write_raw()

      nil
    end

    def gzfile_writer_end
      return if @gz.z.ZSTREAM_IS_CLOSING()
      @gz.z.flags |= ZSTREAM_FLAG_CLOSING
      begin
        gzfile_writer_end_run()
      ensure
        @gz.z.zstream_end()
      end
    end
  end
end
