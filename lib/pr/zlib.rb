# frozen_string_literal: true

# zlib.rb -- An interface for rbzlib
# Copyright (C) UENO Katsuhiro 2000-2003
#
# Ruby translation by Park Heesob

require_relative 'rbzlib'
require_relative 'zlib/errors'
require_relative 'zlib/zstream'
require_relative 'zlib/deflate'
require_relative 'zlib/inflate'
require_relative 'zlib/gzipfile'
require_relative 'zlib/gzipwriter'
require_relative 'zlib/gzipreader'

include Rbzlib

module Zlib

  RUBY_ZLIB_VERSION = '0.6.0'.freeze
  PR_ZLIB_VERSION   = '1.1.0'.freeze

  VERSION = RUBY_ZLIB_VERSION
  ZLIB_VERSION = Rbzlib::ZLIB_VERSION

  BINARY  = Z_BINARY
  ASCII   = Z_ASCII
  UNKNOWN = Z_UNKNOWN

  NO_COMPRESSION      = Z_NO_COMPRESSION
  BEST_SPEED          = Z_BEST_SPEED
  BEST_COMPRESSION    = Z_BEST_COMPRESSION
  DEFAULT_COMPRESSION = Z_DEFAULT_COMPRESSION

  FILTERED         = Z_FILTERED
  HUFFMAN_ONLY     = Z_HUFFMAN_ONLY
  DEFAULT_STRATEGY = Z_DEFAULT_STRATEGY
  MAX_WBITS        = Rbzlib::MAX_WBITS
  DEF_MEM_LEVEL    = Rbzlib::DEF_MEM_LEVEL
  MAX_MEM_LEVEL    = Rbzlib::MAX_MEM_LEVEL
  NO_FLUSH         = Z_NO_FLUSH
  SYNC_FLUSH       = Z_SYNC_FLUSH
  FULL_FLUSH       = Z_FULL_FLUSH
  FINISH           = Z_FINISH

  OS_CODE   = Rbzlib::OS_CODE
  OS_MSDOS  = 0x00
  OS_AMIGA  = 0x01
  OS_VMS    = 0x02
  OS_UNIX   = 0x03
  OS_ATARI  = 0x05
  OS_OS2    = 0x06
  OS_MACOS  = 0x07
  OS_TOPS20 = 0x0a
  OS_WIN32  = 0x0b

  ZSTREAM_FLAG_READY     = 0x1
  ZSTREAM_FLAG_IN_STREAM = 0x2
  ZSTREAM_FLAG_FINISHED  = 0x4
  ZSTREAM_FLAG_CLOSING   = 0x8
  ZSTREAM_FLAG_UNUSED    = 0x10

  ZSTREAM_INITIAL_BUFSIZE = 1024
  ZSTREAM_AVAIL_OUT_STEP_MAX = 16384
  ZSTREAM_AVAIL_OUT_STEP_MIN = 2048

  ZStreamFuncs = Struct.new(:reset, :end, :run)
  DeflateFuncs = ZStreamFuncs.new(:deflateReset, :deflateEnd, :deflate)
  InflateFuncs = ZStreamFuncs.new(:inflateReset, :inflateEnd, :inflate)

  module_function

  def zlib_version
    zlibVersion()
  end

  def adler32(string = nil, adler = nil)
    if adler
      check_long_range adler
      sum = adler
    elsif string.nil?
      sum = 0
    else
      sum = Rbzlib.adler32(0, nil)
    end

    if string.nil?
      sum = Rbzlib.adler32(sum, nil)
    else
      sum = Rbzlib.adler32(sum, string, string.length)
    end
    sum
  end

  def crc32(string = nil, crc = nil)
    if crc
      check_long_range crc
      sum = crc
    elsif string.nil?
      sum = 0
    else
      sum = Rbzlib.crc32(0, nil)
    end

    if string.nil?
      sum = Rbzlib.crc32(sum, nil)
    else
      sum = Rbzlib.crc32(sum, string, string.length)
    end
    sum
  end

  def crc_table
    get_crc_table
  end

  private

  LONG_MAX = 2**64 - 1
  LONG_MIN = -2**63

  def self.check_long_range(num)
    # the error says 'unsigned', but this seems to be the range actually accepted
    raise RangeError, 'bignum too big to convert into `unsigned long\'' if num < LONG_MIN || num > LONG_MAX
  end

end
