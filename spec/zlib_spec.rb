# frozen_string_literal: true

########################################################################
# zlib_spec.rb
#
# Spec for the Zlib module.
########################################################################
require 'spec_helper'

RSpec.describe Zlib do
  let(:zstream_funcs) { described_class::ZStreamFuncs.new }

  describe 'version constants' do
    it 'has the correct Ruby zlib version' do
      expect(described_class::VERSION).to eq('0.6.0')
      expect(described_class::RUBY_ZLIB_VERSION).to eq('0.6.0')
    end

    it 'has the correct zlib version' do
      expect(described_class::ZLIB_VERSION).to eq('1.2.3')
      expect(described_class::PR_ZLIB_VERSION).to eq('1.0.7')
    end
  end

  describe 'data type constants' do
    it 'includes data type constants' do
      expect(described_class::BINARY).not_to be_nil
      expect(described_class::ASCII).not_to be_nil
      expect(described_class::UNKNOWN).not_to be_nil
    end
  end

  describe 'compression constants' do
    it 'includes compression level constants' do
      expect(described_class::NO_COMPRESSION).not_to be_nil
      expect(described_class::BEST_SPEED).not_to be_nil
      expect(described_class::BEST_COMPRESSION).not_to be_nil
      expect(described_class::DEFAULT_COMPRESSION).not_to be_nil
    end
  end

  describe 'encoding constants' do
    it 'includes encoding strategy constants' do
      expect(described_class::FILTERED).not_to be_nil
      expect(described_class::HUFFMAN_ONLY).not_to be_nil
      expect(described_class::DEFAULT_STRATEGY).not_to be_nil
      expect(described_class::MAX_WBITS).not_to be_nil
      expect(described_class::DEF_MEM_LEVEL).not_to be_nil
      expect(described_class::MAX_MEM_LEVEL).not_to be_nil
      expect(described_class::NO_FLUSH).not_to be_nil
      expect(described_class::SYNC_FLUSH).not_to be_nil
      expect(described_class::FULL_FLUSH).not_to be_nil
      expect(described_class::FINISH).not_to be_nil
    end
  end

  describe 'OS constants' do
    it 'has the correct OS constant values' do
      expect(described_class::OS_MSDOS).to eq(0x00)
      expect(described_class::OS_AMIGA).to eq(0x01)
      expect(described_class::OS_VMS).to eq(0x02)
      expect(described_class::OS_UNIX).to eq(0x03)
      expect(described_class::OS_ATARI).to eq(0x05)
      expect(described_class::OS_OS2).to eq(0x06)
      expect(described_class::OS_MACOS).to eq(0x07)
      expect(described_class::OS_TOPS20).to eq(0x0a)
      expect(described_class::OS_WIN32).to eq(0x0b)
    end
  end

  describe 'zstream flag constants' do
    it 'has the correct flag values' do
      expect(described_class::ZSTREAM_FLAG_READY).to eq(0x1)
      expect(described_class::ZSTREAM_FLAG_IN_STREAM).to eq(0x2)
      expect(described_class::ZSTREAM_FLAG_FINISHED).to eq(0x4)
      expect(described_class::ZSTREAM_FLAG_CLOSING).to eq(0x8)
      expect(described_class::ZSTREAM_FLAG_UNUSED).to eq(0x10)
    end
  end

  describe 'zstream buffer constants' do
    it 'has the correct buffer size values' do
      expect(described_class::ZSTREAM_INITIAL_BUFSIZE).to eq(1024)
      expect(described_class::ZSTREAM_AVAIL_OUT_STEP_MAX).to eq(16384)
      expect(described_class::ZSTREAM_AVAIL_OUT_STEP_MIN).to eq(2048)
    end
  end

  describe '.zlib_version' do
    it 'responds to zlib_version' do
      expect(described_class).to respond_to(:zlib_version)
    end
  end

  describe '.adler32' do
    it 'responds to adler32' do
      expect(described_class).to respond_to(:adler32)
    end

    it 'can be called without arguments' do
      expect { described_class.adler32 }.not_to raise_error
    end

    it 'returns correct values' do
      expect(described_class.adler32).to eq(1)
      expect(described_class.adler32('test')).to eq(73204161)
      expect(described_class.adler32(nil, 3)).to eq(1)
      expect(described_class.adler32('test', 3)).to eq(73728451)
    end

    it 'raises RangeError for values too large' do
      expect { described_class.adler32('test', 2**128) }.to raise_error(RangeError)
    end
  end

  describe '.crc32' do
    it 'responds to crc32' do
      expect(described_class).to respond_to(:crc32)
    end

    it 'can be called without arguments' do
      expect { described_class.crc32 }.not_to raise_error
    end

    it 'returns correct values' do
      expect(described_class.crc32).to eq(0)
      expect(described_class.crc32('test')).to eq(3632233996)
      expect(described_class.crc32(nil, 3)).to eq(0)
      expect(described_class.crc32('test', 3)).to eq(3402289634)
    end

    it 'raises RangeError for values too large' do
      expect { described_class.crc32('test', 2**128) }.to raise_error(RangeError)
    end
  end

  describe '.crc_table' do
    it 'responds to crc_table' do
      expect(described_class).to respond_to(:crc_table)
    end

    it 'returns an array' do
      expect { described_class.crc_table }.not_to raise_error
      expect(described_class.crc_table).to be_a(Array)
    end
  end

  describe 'ZStreamFuncs struct' do
    it 'is a ZStreamFuncs instance' do
      expect(zstream_funcs).to be_a(described_class::ZStreamFuncs)
    end

    it 'responds to struct methods' do
      expect(zstream_funcs).to respond_to(:reset)
      expect(zstream_funcs).to respond_to(:end)
      expect(zstream_funcs).to respond_to(:run)
    end
  end

  describe 'error classes' do
    it 'defines Error class' do
      expect(described_class::Error).not_to be_nil
      expect(described_class::Error.new).to be_a(StandardError)
    end

    it 'defines StreamEnd class' do
      expect(described_class::StreamEnd).not_to be_nil
      expect(described_class::StreamEnd.new).to be_a(described_class::Error)
    end

    it 'defines NeedDict class' do
      expect(described_class::NeedDict.new).to be_a(described_class::Error)
    end

    it 'defines DataError class' do
      expect(described_class::DataError.new).to be_a(described_class::Error)
    end

    it 'defines StreamError class' do
      expect(described_class::StreamError.new).to be_a(described_class::Error)
    end

    it 'defines MemError class' do
      expect(described_class::MemError.new).to be_a(described_class::Error)
    end

    it 'defines BufError class' do
      expect(described_class::BufError.new).to be_a(described_class::Error)
    end

    it 'defines VersionError class' do
      expect(described_class::VersionError.new).to be_a(described_class::Error)
    end
  end
end
