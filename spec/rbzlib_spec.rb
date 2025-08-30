# frozen_string_literal: true

########################################################################
# rbzlib_spec.rb
#
# Spec for the Rbzlib module.
########################################################################
require 'spec_helper'

RSpec.describe Rbzlib do
  include described_class

  let(:fixnum) { 7 }
  let(:buffer) { 0.chr * 16 }

  describe 'version' do
    it 'has the correct version' do
      expect(ZLIB_VERSION).to eq('1.2.3')
    end
  end

  describe 'Fixnum#ord' do
    it 'responds to ord' do
      expect(7).to respond_to(:ord)
    end

    it 'returns the number itself' do
      expect(7.ord).to eq(7)
    end
  end

  describe 'miscellaneous constants' do
    it 'has the correct values' do
      expect(MAX_MEM_LEVEL).to eq(9)
      expect(DEF_MEM_LEVEL).to eq(8)
      expect(MAX_WBITS).to eq(15)
      expect(DEF_WBITS).to eq(MAX_WBITS)
      expect(STORED_BLOCK).to eq(0)
      expect(STATIC_TREES).to eq(1)
      expect(DYN_TREES).to eq(2)
      expect(MIN_MATCH).to eq(3)
      expect(MAX_MATCH).to eq(258)
      expect(PRESET_DICT).to eq(0x20)
      expect(BASE).to eq(65521)
      expect(NMAX).to eq(5552)
      expect(OS_CODE).to eq(0)
      expect(SEEK_CUR).to eq(1)
      expect(SEEK_END).to eq(2)
    end
  end

  describe 'sync constants' do
    it 'has the correct values' do
      expect(Z_NO_FLUSH).to eq(0)
      expect(Z_PARTIAL_FLUSH).to eq(1)
      expect(Z_SYNC_FLUSH).to eq(2)
      expect(Z_FULL_FLUSH).to eq(3)
      expect(Z_FINISH).to eq(4)
      expect(Z_BLOCK).to eq(5)
    end
  end

  describe 'stream constants' do
    it 'has the correct values' do
      expect(Z_OK).to eq(0)
      expect(Z_STREAM_END).to eq(1)
      expect(Z_NEED_DICT).to eq(2)
      expect(Z_ERRNO).to eq(-1)
      expect(Z_EOF).to eq(-1)
      expect(Z_STREAM_ERROR).to eq(-2)
      expect(Z_DATA_ERROR).to eq(-3)
      expect(Z_MEM_ERROR).to eq(-4)
      expect(Z_BUF_ERROR).to eq(-5)
      expect(Z_VERSION_ERROR).to eq(-6)
      expect(Z_BUFSIZE).to eq(16384)
    end
  end

  describe 'compression constants' do
    it 'has the correct values' do
      expect(Z_NO_COMPRESSION).to eq(0)
      expect(Z_BEST_SPEED).to eq(1)
      expect(Z_BEST_COMPRESSION).to eq(9)
      expect(Z_DEFAULT_COMPRESSION).to eq(-1)
      expect(Z_DEFLATED).to eq(8)
    end
  end

  describe 'encoding constants' do
    it 'has the correct values' do
      expect(Z_FILTERED).to eq(1)
      expect(Z_HUFFMAN_ONLY).to eq(2)
      expect(Z_RLE).to eq(3)
      expect(Z_FIXED).to eq(4)
      expect(Z_DEFAULT_STRATEGY).to eq(0)
    end
  end

  describe 'CRC constants' do
    it 'has the correct values' do
      expect(ASCII_FLAG).to eq(0x01)
      expect(HEAD_CRC).to eq(0x02)
      expect(EXTRA_FIELD).to eq(0x04)
      expect(ORIG_NAME).to eq(0x08)
      expect(COMMENT_).to eq(0x10)
      expect(RESERVED).to eq(0xE0)
    end
  end

  describe '#zError' do
    it 'responds to zError' do
      expect(self).to respond_to(:zError)
    end

    it 'returns correct error messages' do
      expect(zError(Z_STREAM_END)).to eq('stream end')
    end
  end

  describe '#zlibVersion' do
    it 'responds to zlibVersion' do
      expect(self).to respond_to(:zlibVersion)
    end

    it 'returns the zlib version' do
      expect(zlibVersion).to eq(ZLIB_VERSION)
    end
  end

  describe '#z_error' do
    it 'responds to z_error' do
      expect(self).to respond_to(:z_error)
    end

    it 'raises RuntimeError' do
      expect { z_error('hello') }.to raise_error(RuntimeError)
    end
  end

  describe '.adler32' do
    it 'responds to adler32' do
      expect(described_class).to respond_to(:adler32)
    end

    it 'returns correct values' do
      expect(described_class.adler32(32, nil)).to eq(1)
      expect(described_class.adler32(0, buffer)).to eq(0)
      expect(described_class.adler32(1, buffer)).to eq(1048577)
      expect(described_class.adler32(10, buffer)).to eq(10485770)
      expect(described_class.adler32(32, buffer)).to eq(33554464)
    end

    it 'raises ArgumentError with wrong arguments' do
      expect { described_class.adler32 }.to raise_error(ArgumentError)
      expect { described_class.adler32('test') }.to raise_error(ArgumentError)
    end
  end

  describe '.get_crc_table' do
    it 'responds to get_crc_table' do
      expect(described_class).to respond_to(:get_crc_table)
    end
  end

  describe '.gz_open' do
    it 'responds to gz_open' do
      expect(described_class).to respond_to(:gz_open)
    end
  end
end
