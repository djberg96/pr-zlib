# frozen_string_literal: true

########################################################################
# rbzlib_bytef_spec.rb
#
# Spec for the Rbzlib::Bytef class.
########################################################################
require 'spec_helper'
require 'pr/rbzlib'

RSpec.describe Rbzlib::Bytef do
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
      expect { bytef + 1 }.not_to raise_error
      expect(bytef.offset).to eq(1)
    end

    it 'responds to -' do
      expect(bytef).to respond_to(:-)
    end

    it 'decrements the offset' do
      expect { bytef - 1 }.not_to raise_error
      expect(bytef.offset).to eq(-1)
    end
  end

  describe 'array access' do
    it 'responds to []' do
      expect(bytef).to respond_to(:[])
    end

    it 'reads from the buffer' do
      expect { bytef[1] }.not_to raise_error
      expect(bytef[1]).to eq(0)
    end

    it 'responds to []=' do
      expect(bytef).to respond_to(:[]=)
    end

    it 'writes to the buffer' do
      expect { bytef[1] = 1.chr }.not_to raise_error
      expect(bytef[1]).to eq(1)
    end
  end

  describe '#get' do
    it 'responds to get' do
      expect(bytef).to respond_to(:get)
    end

    it 'gets the current value' do
      expect { bytef.get }.not_to raise_error
      expect(bytef.get).to eq(0)
    end
  end

  describe '#set' do
    it 'responds to set' do
      expect(bytef).to respond_to(:set)
    end

    it 'sets the current value' do
      expect { bytef.set('a') }.not_to raise_error
      expect(bytef.get).to eq(97)
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
