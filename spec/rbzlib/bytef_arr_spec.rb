# frozen_string_literal: true

########################################################################
# bytef_arr_spec.rb
#
# Spec for the Rbzlib::Bytef_arr class.
########################################################################
require 'spec_helper'
require 'pr/rbzlib/bytef_arr'

RSpec.describe Rbzlib::Bytef_arr do
  let(:buffer) { Array.new(32, 0) }
  let(:bytef) { described_class.new(buffer) }

  describe 'inheritance' do
    it 'inherits from Bytef_str' do
      expect(described_class.superclass).to eq(Rbzlib::Bytef_str)
    end
  end

  describe 'array access' do
    it 'responds to []' do
      expect(bytef).to respond_to(:[])
    end

    it 'reads from the buffer' do
      expect { bytef[0] }.not_to raise_error
      expect(bytef[0]).to eq(0)
    end

    it 'responds to []=' do
      expect(bytef).to respond_to(:[]=)
    end

    it 'writes to the buffer' do
      expect { bytef[0] = 65 }.not_to raise_error
      expect(bytef[0]).to eq(65)
    end
  end

  describe '#get' do
    it 'responds to get' do
      expect(bytef).to respond_to(:get)
    end

    it 'gets the current value' do
      expect(bytef.get).to eq(0)
    end
  end

  describe '#set' do
    it 'responds to set' do
      expect(bytef).to respond_to(:set)
    end

    it 'sets the current value' do
      expect { bytef.set(42) }.not_to raise_error
      expect(bytef.get).to eq(42)
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
end
