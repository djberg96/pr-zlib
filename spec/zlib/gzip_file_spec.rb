# frozen_string_literal: true

########################################################################
# gzip_file_spec.rb
#
# Spec for the Zlib::GzipFile base class.
########################################################################
require 'spec_helper'

RSpec.describe Zlib::GzipFile do
  let(:gz_file) { described_class.new }

  describe 'constants' do
    it 'has the correct constant values' do
      expect(described_class::GZ_MAGIC1).to eq(0x1f)
      expect(described_class::GZ_MAGIC2).to eq(0x8b)
      expect(described_class::GZ_METHOD_DEFLATE).to eq(8)
      expect(described_class::GZ_FLAG_MULTIPART).to eq(0x2)
      expect(described_class::GZ_FLAG_EXTRA).to eq(0x4)
      expect(described_class::GZ_FLAG_ORIG_NAME).to eq(0x8)
      expect(described_class::GZ_FLAG_COMMENT).to eq(0x10)
      expect(described_class::GZ_FLAG_ENCRYPT).to eq(0x20)
      expect(described_class::GZ_FLAG_UNKNOWN_MASK).to eq(0xc0)
      expect(described_class::GZ_EXTRAFLAG_FAST).to eq(0x4)
      expect(described_class::GZ_EXTRAFLAG_SLOW).to eq(0x2)
    end
  end

  describe 'instance methods' do
    it 'responds to GZFILE_IS_FINISHED' do
      expect(gz_file).to respond_to(:GZFILE_IS_FINISHED)
    end

    it 'responds to gzfile_close' do
      expect(gz_file).to respond_to(:gzfile_close)
    end

    it 'responds to to_io' do
      expect(gz_file).to respond_to(:to_io)
    end

    it 'responds to crc' do
      expect(gz_file).to respond_to(:crc)
    end

    it 'responds to mtime' do
      expect(gz_file).to respond_to(:mtime)
    end

    it 'responds to level' do
      expect(gz_file).to respond_to(:level)
    end

    it 'responds to os_code' do
      expect(gz_file).to respond_to(:os_code)
    end

    it 'responds to orig_name' do
      expect(gz_file).to respond_to(:orig_name)
    end

    it 'responds to comment' do
      expect(gz_file).to respond_to(:comment)
    end

    it 'responds to close' do
      expect(gz_file).to respond_to(:close)
    end

    it 'responds to finish' do
      expect(gz_file).to respond_to(:finish)
    end

    it 'responds to closed?' do
      expect(gz_file).to respond_to(:closed?)
    end

    it 'responds to sync' do
      expect(gz_file).to respond_to(:sync)
    end

    it 'responds to sync=' do
      expect(gz_file).to respond_to(:sync=)
    end
  end
end
