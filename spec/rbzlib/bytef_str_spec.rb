# frozen_string_literal: true

########################################################################
# bytef_str_spec.rb
#
# Spec for the Rbzlib::Bytef_str class.
########################################################################
require 'spec_helper'
require 'pr/rbzlib/bytef_str'

RSpec.describe Rbzlib::Bytef_str do
  let(:buffer) { 0.chr * 32 }
  let(:bytef) { described_class.new(buffer) }

  describe '#buffer' do
    it 'responds to buffer getter' do
      expect(bytef).to respond_to(:buffer)
    end

    it 'returns the buffer' do
      expect(bytef.buffer).to eq(buffer)
    end

    it 'responds to buffer setter' do
      expect(bytef).to respond_to(:buffer=)
    end

    it 'sets the buffer' do
      new_buffer = 0.chr * 8
      expect { bytef.buffer = new_buffer }.not_to raise_error
      expect(bytef.buffer).to eq(new_buffer)
    end
  end

  describe '#length' do
    it 'responds to length' do
      expect(bytef).to respond_to(:length)
    end

    it 'returns the correct length' do
      expect(bytef.length).to eq(32)
    end
  end

  describe 'arithmetic operations' do
    it 'responds to +' do
      expect(bytef).to respond_to(:+)
    end

    it 'increments the offset' do
      expect { bytef + 4 }.not_to raise_error
      expect(bytef.offset).to eq(4)
    end

    it 'responds to -' do
      expect(bytef).to respond_to(:-)
    end

    it 'decrements the offset' do
      bytef + 8
      bytef - 4
      expect(bytef.offset).to eq(4)
    end
  end

  describe 'array access' do
    it 'responds to []' do
      expect(bytef).to respond_to(:[])
    end

    it 'reads from the buffer' do
      expect { bytef[0] }.not_to raise_error
    end

    it 'responds to []=' do
      expect(bytef).to respond_to(:[]=)
    end

    it 'writes to the buffer' do
      expect { bytef[0] = 'A' }.not_to raise_error
    end
  end

  describe '#get' do
    it 'responds to get' do
      expect(bytef).to respond_to(:get)
    end

    it 'gets the current value' do
      expect { bytef.get }.not_to raise_error
    end
  end

  describe '#set' do
    it 'responds to set' do
      expect(bytef).to respond_to(:set)
    end

    it 'sets the current value' do
      expect { bytef.set('A') }.not_to raise_error
    end
  end

  describe '#current' do
    it 'responds to current' do
      expect(bytef).to respond_to(:current)
    end

    it 'returns the current buffer' do
      expect(bytef.current).to eq(buffer)
    end
  end
end
