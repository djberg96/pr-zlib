# frozen_string_literal: true

########################################################################
# gzip_writer_spec.rb
#
# Spec for the Zlib::GzipWriter class.
########################################################################
require 'spec_helper'

RSpec.describe Zlib::GzipWriter do
  before(:all) do
    @gz_file = 'gzip_writer_test.gz'
  end

  after(:all) do
    File.delete(@gz_file) if File.exist?(@gz_file)
  end

  let(:handle) { File.new(@gz_file, 'w') }
  let(:writer) { described_class.new(handle) }
  let(:time) { Time.now }

  after do
    handle.close if handle && !handle.closed?
  end

  describe 'constructor' do
    it 'can be created with just a handle' do
      expect { described_class.new(handle) }.not_to raise_error
    end

    it 'can be created with handle and level' do
      expect { described_class.new(handle, nil) }.not_to raise_error
    end

    it 'can be created with handle, level, and strategy' do
      expect { described_class.new(handle, nil, nil) }.not_to raise_error
    end

    it 'raises ArgumentError with no arguments' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end
  end

  describe '#level' do
    it 'responds to level' do
      expect(writer).to respond_to(:level)
    end

    it 'returns the default compression level' do
      expect(writer.level).to eq(Rbzlib::Z_DEFAULT_COMPRESSION)
    end
  end

  describe '#mtime' do
    it 'responds to mtime getter' do
      expect(writer).to respond_to(:mtime)
    end

    it 'can get mtime without errors' do
      expect { writer.mtime }.not_to raise_error
    end

    it 'returns a Time object' do
      expect(writer.mtime).to be_a(Time)
    end

    it 'starts at Time.at(0)' do
      expect(writer.mtime).to eq(Time.at(0))
    end

    it 'responds to mtime setter' do
      expect(writer).to respond_to(:mtime=)
    end

    it 'can set mtime without errors' do
      expect { writer.mtime = time }.not_to raise_error
    end

    it 'returns the set value' do
      expect(writer.mtime = time).to eq(time)
    end
  end

  describe '#orig_name' do
    it 'responds to orig_name getter' do
      expect(writer).to respond_to(:orig_name)
    end

    it 'can get orig_name without errors' do
      expect { writer.orig_name }.not_to raise_error
    end

    it 'returns nil initially' do
      expect(writer.orig_name).to be_nil
    end

    it 'responds to orig_name setter' do
      expect(writer).to respond_to(:orig_name=)
    end

    it 'can set orig_name without errors' do
      expect { writer.orig_name = 'test' }.not_to raise_error
    end

    it 'returns and stores the set value' do
      expect(writer.orig_name = 'test').to eq('test')
      expect(writer.orig_name).to eq('test')
    end
  end

  describe '#comment' do
    it 'responds to comment getter' do
      expect(writer).to respond_to(:comment)
    end

    it 'can get comment without errors' do
      expect { writer.comment }.not_to raise_error
    end

    it 'returns nil initially' do
      expect(writer.comment).to be_nil
    end

    it 'responds to comment setter' do
      expect(writer).to respond_to(:comment=)
    end

    it 'can set comment without errors' do
      expect { writer.comment = 'test' }.not_to raise_error
    end

    it 'returns and stores the set value' do
      expect(writer.comment = 'test').to eq('test')
      expect(writer.comment).to eq('test')
    end
  end

  describe '#pos' do
    it 'responds to pos' do
      expect(writer).to respond_to(:pos)
    end

    it 'can get pos without errors' do
      expect { writer.pos }.not_to raise_error
    end

    it 'returns an integer' do
      expect(writer.pos).to be_a(Integer)
    end

    it 'starts at 0' do
      expect(writer.pos).to eq(0)
    end

    it 'updates after writing' do
      expect { writer.write('test') }.not_to raise_error
      expect(writer.pos).to eq(4)
    end

    it 'has tell as an alias' do
      expect(writer.method(:pos)).to eq(writer.method(:tell))
    end
  end

  describe '.open' do
    it 'responds to open class method' do
      expect(described_class).to respond_to(:open)
    end

    it 'can open with block without errors' do
      expect { described_class.open(@gz_file) {} }.not_to raise_error
    end
  end

  describe '#flush' do
    it 'responds to flush' do
      expect(writer).to respond_to(:flush)
    end

    it 'can flush without errors' do
      expect { writer.flush }.not_to raise_error
    end

    it 'returns self' do
      expect(writer.flush).to eq(writer)
    end
  end

  describe '#write' do
    it 'responds to write' do
      expect(writer).to respond_to(:write)
    end

    it 'can write without errors' do
      expect { writer.write('test') }.not_to raise_error
    end

    it 'returns number of bytes written for string' do
      expect(writer.write('test')).to eq(4)
    end

    it 'returns number of bytes written for number' do
      expect(writer.write(999)).to eq(3)
    end

    it 'raises ArgumentError with no arguments' do
      expect { writer.write }.to raise_error(ArgumentError)
    end
  end

  describe '#putc' do
    it 'responds to putc' do
      expect(writer).to respond_to(:putc)
    end

    it 'can putc without errors' do
      expect { writer.putc(97) }.not_to raise_error
    end

    it 'returns the character code' do
      expect(writer.putc(97)).to eq(97)
    end

    it 'raises ArgumentError with no arguments' do
      expect { writer.putc }.to raise_error(ArgumentError)
    end
  end

  describe '#<<' do
    it 'responds to <<' do
      expect(writer).to respond_to(:<<)
    end

    it 'can append without errors' do
      expect { writer << 'test' }.not_to raise_error
    end

    it 'raises ArgumentError with no arguments' do
      expect { writer.send(:<<) }.to raise_error(ArgumentError)
    end
  end

  describe '#printf' do
    it 'responds to printf' do
      expect(writer).to respond_to(:printf)
    end

    it 'can printf without errors' do
      expect { writer.printf('%s', 'test') }.not_to raise_error
    end

    it 'raises ArgumentError with no arguments' do
      expect { writer.printf }.to raise_error(ArgumentError)
    end
  end

  describe '#puts' do
    it 'responds to puts' do
      expect(writer).to respond_to(:puts)
    end

    it 'can puts without errors' do
      expect { writer.puts('test') }.not_to raise_error
    end

    it 'raises ArgumentError with no arguments' do
      expect { writer.puts }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError with multiple arguments' do
      expect { writer.puts('test1', 'test2') }.to raise_error(ArgumentError)
    end
  end
end