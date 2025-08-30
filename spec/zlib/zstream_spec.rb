# frozen_string_literal: true

########################################################################
# zstream_spec.rb
#
# Spec for the Zlib::ZStream class.
########################################################################
require 'spec_helper'

RSpec.describe Zlib::ZStream do
  let(:zstream) { described_class.new }
  let(:zfunc) { Zlib::ZStreamFuncs.new }
  let(:src) { Array.new(128, 0.chr) }

  before do
    zstream.zstream_init(zfunc)
  end

  describe 'accessors' do
    it 'has flags accessor' do
      expect(zstream).to respond_to(:flags)
      expect(zstream).to respond_to(:flags=)
    end

    it 'has buf accessor' do
      expect(zstream).to respond_to(:buf)
      expect(zstream).to respond_to(:buf=)
    end

    it 'has input accessor' do
      expect(zstream).to respond_to(:input)
      expect(zstream).to respond_to(:input=)
    end

    it 'has stream accessor' do
      expect(zstream).to respond_to(:stream)
      expect(zstream).to respond_to(:stream=)
    end

    it 'has func accessor' do
      expect(zstream).to respond_to(:func)
      expect(zstream).to respond_to(:func=)
    end
  end

  describe '#raise_zlib_error' do
    it 'responds to raise_zlib_error' do
      expect(zstream).to respond_to(:raise_zlib_error)
    end

    it 'raises StreamEnd for Z_STREAM_END' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_STREAM_END, nil) }.to raise_error(Zlib::StreamEnd, 'stream end')
    end

    it 'raises NeedDict for Z_NEED_DICT' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_NEED_DICT, nil) }.to raise_error(Zlib::NeedDict, 'need dictionary')
    end

    it 'raises StreamError for Z_STREAM_ERROR' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_STREAM_ERROR, nil) }.to raise_error(Zlib::StreamError, 'stream error')
    end

    it 'raises DataError for Z_DATA_ERROR' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_DATA_ERROR, nil) }.to raise_error(Zlib::DataError, 'data error')
    end

    it 'raises BufError for Z_BUF_ERROR' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_BUF_ERROR, nil) }.to raise_error(Zlib::BufError, 'buffer error')
    end

    it 'raises VersionError for Z_VERSION_ERROR' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_VERSION_ERROR, nil) }.to raise_error(Zlib::VersionError, 'incompatible version')
    end

    it 'raises MemError for Z_MEM_ERROR' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_MEM_ERROR, nil) }.to raise_error(Zlib::MemError, 'insufficient memory')
    end

    it 'raises SystemCallError for Z_ERRNO' do
      expect { zstream.raise_zlib_error(Rbzlib::Z_ERRNO, nil) }.to raise_error(SystemCallError)
    end

    it 'raises Error for unknown error codes' do
      expect { zstream.raise_zlib_error(999, nil) }.to raise_error(Zlib::Error)
    end
  end

  describe '#zstream_expand_buffer' do
    it 'responds to zstream_expand_buffer' do
      expect(zstream).to respond_to(:zstream_expand_buffer)
    end

    it 'expands buffer without errors' do
      expect { zstream.zstream_expand_buffer }.not_to raise_error
    end

    it 'sets buf after call' do
      expect(zstream.buf).to be_nil
      zstream.zstream_expand_buffer
      expect(zstream.buf).to be_a(Bytef_str)
    end

    it 'raises ArgumentError with wrong number of arguments' do
      expect { zstream.zstream_expand_buffer(1) }.to raise_error(ArgumentError)
    end
  end

  describe '#zstream_append_buffer' do
    it 'responds to zstream_append_buffer' do
      expect(zstream).to respond_to(:zstream_append_buffer)
    end

    it 'appends buffer without errors' do
      expect { zstream.zstream_append_buffer(src, src.length) }.not_to raise_error
    end

    it 'sets buf after call' do
      expect(zstream.buf).to be_nil
      zstream.zstream_append_buffer(src, src.length)
      expect(zstream.buf).to be_a(Bytef_arr)
    end

    it 'raises ArgumentError without arguments' do
      expect { zstream.zstream_append_buffer }.to raise_error(ArgumentError)
    end
  end

  describe '#zstream_detach_buffer' do
    it 'responds to zstream_detach_buffer' do
      expect(zstream).to respond_to(:zstream_detach_buffer)
    end

    it 'detaches buffer without errors' do
      expect { zstream.zstream_detach_buffer }.not_to raise_error
    end

    it 'returns a string' do
      expect(zstream.zstream_detach_buffer).to be_a(String)
      expect(zstream.buf).not_to be_nil
    end
  end

  describe '#zstream_shift_buffer' do
    before do
      zstream.buf = Bytef.new(0.chr * Zlib::ZSTREAM_INITIAL_BUFSIZE)
    end

    it 'responds to zstream_shift_buffer' do
      expect(zstream).to respond_to(:zstream_shift_buffer)
    end

    it 'shifts buffer without errors' do
      expect { zstream.zstream_shift_buffer(1) }.not_to raise_error
    end
  end
end
