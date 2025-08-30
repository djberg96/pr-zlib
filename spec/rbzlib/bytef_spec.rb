# frozen_string_literal: true

########################################################################
# bytef_spec.rb
#
# Spec for the Rbzlib::Bytef factory class.
########################################################################
require 'spec_helper'
require 'pr/rbzlib/bytef'

RSpec.describe Rbzlib::Bytef do
  describe '.new' do
    context 'with string buffer' do
      let(:string_buffer) { +'hello world' }  # Make string mutable

      it 'returns a Bytef_str instance' do
        result = described_class.new(string_buffer)
        expect(result).to be_a(Rbzlib::Bytef_str)
      end

      it 'initializes with the correct buffer' do
        result = described_class.new(string_buffer)
        expect(result.buffer).to eq(string_buffer)
      end

      it 'initializes with default offset 0' do
        result = described_class.new(string_buffer)
        expect(result.offset).to eq(0)
      end

      it 'initializes with custom offset' do
        result = described_class.new(string_buffer, 5)
        expect(result.offset).to eq(5)
      end
    end

    context 'with array buffer' do
      let(:array_buffer) { [65, 66, 67, 68, 69] }

      it 'returns a Bytef_arr instance' do
        result = described_class.new(array_buffer)
        expect(result).to be_a(Rbzlib::Bytef_arr)
      end

      it 'initializes with the correct buffer' do
        result = described_class.new(array_buffer)
        expect(result.buffer).to eq(array_buffer)
      end

      it 'initializes with default offset 0' do
        result = described_class.new(array_buffer)
        expect(result.offset).to eq(0)
      end

      it 'initializes with custom offset' do
        result = described_class.new(array_buffer, 3)
        expect(result.offset).to eq(3)
      end
    end

    context 'factory behavior' do
      it 'creates appropriate instance based on buffer type' do
        string_result = described_class.new(+'test')  # Make string mutable
        array_result = described_class.new([1, 2, 3])

        expect(string_result.class).not_to eq(array_result.class)
        expect(string_result).to be_a(Rbzlib::Bytef_str)
        expect(array_result).to be_a(Rbzlib::Bytef_arr)
      end
    end
  end
end
