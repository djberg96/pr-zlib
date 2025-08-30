# frozen_string_literal: true

require_relative 'zstream'

module Zlib
  class Inflate < ZStream

    def self.inflate_run(src)
      @z.zstream_run(src, src.length, Z_SYNC_FLUSH)
      @z.zstream_run('', 0, Z_FINISH)
      @z.zstream_detach_buffer()
    end

    def self.inflate(src)
      @z = ZStream.new
      @z.zstream_init(InflateFuncs)
      err = inflateInit(@z.stream)
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end
      @z.ZSTREAM_READY()
      begin
        dst = inflate_run(src)
      ensure
        @z.zstream_end
      end
      dst
    end

    def do_inflate(src)
      if src.nil?
        @z.zstream_run('', 0, Z_FINISH)
        return
      end
      if src.length > 0
        @z.zstream_run(src, src.length, Z_SYNC_FLUSH)
      end
    end
    private :do_inflate

    def initialize(wbits = MAX_WBITS)
      @z = ZStream.new
      @z.zstream_init(InflateFuncs)
      err = inflateInit2(@z.stream, wbits)
      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end
      @z.ZSTREAM_READY()
    end

    def inflate(src)
      if @z.ZSTREAM_IS_FINISHED()
        if src.nil?
          dst = @z.zstream_detach_buffer()
        else
          @z.zstream_append_buffer(src, src.lenth)
          dst = ''
        end
      else
        do_inflate(src)
        dst = @z.zstream_detach_buffer()
        if @z.ZSTREAM_IS_FINISHED()
          @z.zstream_passthrough_input()
        end
      end
      if block_given?
	      yield dst
      else
        dst
      end
    end

    def <<(src)
      if @z.ZSTREAM_IS_FINISHED()
        if src
          @z.zstream_append_buffer(src, src.length)
        end
      else
        do_inflate(src)
        if @z.ZSTREAM_IS_FINISHED()
          @z.zstream_passthrough_input()
        end
      end
      self
    end

    def sync
      raise GzipFile::Error, 'closed gzip stream' unless @gz.z.ZSTREAM_IS_READY()
      @z.zstream_sync(src, src.length)
    end

    def sync_point?
      err = inflateSyncPoint(@z.stream)
      return true if err == 1

      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end

      false
    end

    def set_dictionary(dic)
      src = dic
      err = inflateSetDictionary(@z.stream, src, src.length)

      if err != Z_OK
        raise_zlib_error(err, @z.stream.msg)
      end

      dic
    end
  end
end
