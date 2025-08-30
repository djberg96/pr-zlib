# frozen_string_literal: true

########################################################################
# gzip_reader_spec.rb
#
# Spec for the Zlib::GzipReader class.
########################################################################
require 'spec_helper'
require 'fileutils'

RSpec.describe Zlib::GzipReader do
  before(:all) do
    # Change to spec directory and create test file
    @original_dir = Dir.pwd
    spec_dir = File.join(@original_dir, 'spec')
    Dir.mkdir(spec_dir) unless Dir.exist?(spec_dir)
    Dir.chdir(spec_dir)

    # Create test file and gzip it
    File.open('test.txt', 'wb') { |fh| fh.puts 'Test file' }
    system('gzip *.txt')
    @gz_file = 'test.txt.gz'
  end

  after(:all) do
    # Clean up
    File.delete(@gz_file) if File.exist?(@gz_file)
    Dir.chdir(@original_dir)
  end

  let(:handle) { File.open(@gz_file) }
  let(:gz_reader) { described_class.new(handle) }

  after do
    handle.close if handle && !handle.closed?
  end

  describe 'constructor' do
    it 'raises ArgumentError with no arguments' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'raises NoMethodError with invalid argument' do
      expect { described_class.new(1) }.to raise_error(NoMethodError)
    end
  end

  describe '#lineno' do
    it 'responds to lineno getter' do
      expect(gz_reader).to respond_to(:lineno)
    end

    it 'can get lineno without errors' do
      expect { gz_reader.lineno }.not_to raise_error
    end

    it 'returns an integer' do
      expect(gz_reader.lineno).to be_a(Integer)
    end

    it 'starts at 0' do
      expect(gz_reader.lineno).to eq(0)
    end

    it 'responds to lineno setter' do
      expect(gz_reader).to respond_to(:lineno=)
    end

    it 'can set lineno without errors' do
      expect { gz_reader.lineno = 0 }.not_to raise_error
    end

    it 'returns the set value' do
      expect(gz_reader.lineno = 0).to eq(0)
    end
  end

  describe '#eof' do
    it 'responds to eof' do
      expect(gz_reader).to respond_to(:eof)
    end

    it 'can call eof without errors' do
      expect { gz_reader.eof }.not_to raise_error
    end
  end

  describe '#pos' do
    it 'responds to pos' do
      expect(gz_reader).to respond_to(:pos)
    end

    it 'can call pos without errors' do
      expect { gz_reader.pos }.not_to raise_error
    end

    it 'returns an integer' do
      expect(gz_reader.pos).to be_a(Integer)
    end
  end

  describe '#rewind' do
    it 'responds to rewind' do
      expect(gz_reader).to respond_to(:rewind)
    end

    it 'can call rewind without errors' do
      expect { gz_reader.rewind }.not_to raise_error
    end

    it 'returns 0' do
      expect(gz_reader.rewind).to eq(0)
    end
  end

  describe '#unused' do
    it 'responds to unused' do
      expect(gz_reader).to respond_to(:unused)
    end

    it 'can call unused without errors' do
      expect { gz_reader.unused }.not_to raise_error
    end

    it 'returns nil initially' do
      expect(gz_reader.unused).to be_nil
    end
  end

  describe '#read' do
    it 'responds to read' do
      expect(gz_reader).to respond_to(:read)
    end

    it 'can call read without errors' do
      expect { gz_reader.read }.not_to raise_error
    end

    it 'reads the entire file content' do
      expect(gz_reader.read).to eq("Test file\n")
    end

    it 'can read with length parameter' do
      expect(gz_reader.read(4)).to eq("Test")
    end

    it 'raises ArgumentError for negative length' do
      expect { gz_reader.read(-1) }.to raise_error(ArgumentError)
    end
  end

  describe '#getc' do
    it 'responds to getc' do
      expect(gz_reader).to respond_to(:getc)
    end

    it 'can call getc without errors' do
      expect { gz_reader.getc }.not_to raise_error
    end

    it 'returns the first character' do
      expect(gz_reader.getc).to eq('T')
    end
  end

  describe '#readchar' do
    it 'responds to readchar' do
      expect(gz_reader).to respond_to(:readchar)
    end

    it 'can call readchar without errors' do
      expect { gz_reader.readchar }.not_to raise_error
    end

    it 'returns the first character' do
      expect(gz_reader.readchar).to eq('T')
    end
  end

  describe '#each_byte' do
    it 'responds to each_byte' do
      expect(gz_reader).to respond_to(:each_byte)
    end

    it 'can call each_byte without errors' do
      expect { gz_reader.each_byte {} }.not_to raise_error
    end

    it 'returns nil when called with block' do
      expect(gz_reader.each_byte {}).to be_nil
    end
  end

  describe '#ungetc' do
    it 'responds to ungetc' do
      expect(gz_reader).to respond_to(:ungetc)
    end

    it 'can call ungetc without errors' do
      expect { gz_reader.ungetc(99) }.not_to raise_error
    end

    it 'returns nil' do
      expect(gz_reader.ungetc(99)).to be_nil
    end
  end

  describe '#gets' do
    it 'responds to gets' do
      expect(gz_reader).to respond_to(:gets)
    end

    it 'can call gets without errors' do
      expect { gz_reader.gets }.not_to raise_error
    end

    it 'reads a line' do
      expect(gz_reader.gets).to eq("Test file\n")
    end
  end

  describe '#readline' do
    it 'responds to readline' do
      expect(gz_reader).to respond_to(:readline)
    end

    it 'can call readline without errors' do
      expect { gz_reader.readline }.not_to raise_error
    end

    it 'reads a line' do
      expect(gz_reader.readline).to eq("Test file\n")
    end
  end

  describe '#each' do
    it 'responds to each' do
      expect(gz_reader).to respond_to(:each)
    end

    it 'can call each without errors' do
      expect { gz_reader.each {} }.not_to raise_error
    end

    it 'returns non-nil when called with block' do
      expect(gz_reader.each {}).not_to be_nil
    end
  end

  describe '#readlines' do
    it 'responds to readlines' do
      expect(gz_reader).to respond_to(:readlines)
    end

    it 'can call readlines without errors' do
      expect { gz_reader.readlines }.not_to raise_error
    end

    it 'returns array of lines' do
      expect(gz_reader.readlines).to eq(["Test file\n"])
    end
  end
end