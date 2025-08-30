# frozen_string_literal: true

require_relative 'zstream'

module Zlib
  class Deflate < ZStream

    def self.deflate_run(src)
      @z.zstream_run(src, src.length, Z_FINISH)
      @z.zstream_detach_buffer()
    end

    def self.deflate(src, level = Z_DEFAULT_COMPRESSION)
      @z = ZStream.new
      @z.zstream_init(DeflateFuncs)
      err = deflateInit(@z.stream, level)
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end
      @z.ZSTREAM_READY()

      begin
        dst = deflate_run(src)
      ensure
        @z.zstream_end()
      end
      dst
    end

    def initialize(level = Z_DEFAULT_COMPRESSION, wbits = MAX_WBITS, memlevel = DEF_MEM_LEVEL, strategy = Z_DEFAULT_STRATEGY)
      @z = ZStream.new
      @z.zstream_init(DeflateFuncs)
      err = deflateInit2(@z.stream, level, Z_DEFLATED, wbits, memlevel, strategy)
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end
      @z.ZSTREAM_READY()
    end

    def initialize_copy(orig)
      z1 = @z
      z2 = orig.z
      err = deflateCopy(z1.stream, z2.stream)
      if err != Z_OK
        raise_zlib_error(err, 0)
      end
      z1.flags = z2.flags
    end

    def do_deflate(src, flush)
      if src.nil?
        @z.zstream_run('', 0, Z_FINISH)
        return
      end
      if flush != Z_NO_FLUSH || (src && src.length > 0)
        @z.zstream_run(src, src.length, flush)
      end
    end
    private :do_deflate

    def deflate(src, flush = Z_NO_FLUSH)
      do_deflate(src, flush)
      @z.zstream_detach_buffer
    end

    def <<(src)
      do_deflate(src, Z_NO_FLUSH)
      self
    end

    def flush(v_flush)
      if v_flush != Z_NO_FLUSH
        @z.zstream_run('', 0, flush)
      end
      @z.zstream_detach_buffer()
    end

    def params(level = Z_DEFAULT_COMPRESSION, strategy = Z_DEFAULT_STRATEGY)
      err = deflateParams(@z.stream, level, strategy)
      while err == Z_BUF_ERROR
        warn('deflateParams() returned Z_BUF_ERROR')
        @z.zstream_expand_buffer()
        err = deflateParams(@z.stream, level, strategy)
      end
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end

      nil
    end

    def set_dictionary(dic)
      err = deflateSetDictionary(@z.stream, dic, dic.length)
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end
    end
  end
end
