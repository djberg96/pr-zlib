# frozen_string_literal: true

########################################################################
# posf_spec.rb
#
# Spec for the Rbzlib::Posf class.
########################################################################
require 'spec_helper'
require 'pr/rbzlib/posf'

RSpec.describe Rbzlib::Posf do
  let(:buffer) { 0.chr * 32 }
  let(:posf) { described_class.new(buffer) }

  describe 'inheritance' do
    it 'inherits from Bytef_str' do
      expect(described_class.superclass).to eq(Rbzlib::Bytef_str)
    end
  end

  describe 'arithmetic operations' do
    it 'responds to +' do
      expect(posf).to respond_to(:+)
    end

    it 'increments the offset by 2x the value' do
      expect { posf + 4 }.not_to raise_error
      expect(posf.offset).to eq(8)
    end

    it 'responds to -' do
      expect(posf).to respond_to(:-)
    end

    it 'decrements the offset by 2x the value' do
      expect { posf - 4 }.not_to raise_error
      expect(posf.offset).to eq(-8)
    end
  end

  describe 'array access' do
    it 'responds to []' do
      expect(posf).to respond_to(:[])
    end

    it 'reads from the buffer' do
      expect { posf[2] }.not_to raise_error
      expect(posf[2]).to eq(0)
    end

    it 'responds to []=' do
      expect(posf).to respond_to(:[]=)
    end

    it 'writes to the buffer' do
      expect { posf[2] = 7 }.not_to raise_error
      expect(posf[2]).to eq(7)
      expect(posf.buffer[4, 2]).to eq("\a\000")
    end
  end

  describe '#get' do
    it 'responds to get' do
      expect(posf).to respond_to(:get)
    end

    it 'gets the current value' do
      expect { posf.get }.not_to raise_error
      expect(posf.get).to eq(0)
    end
  end

  describe '#set' do
    it 'responds to set' do
      expect(posf).to respond_to(:set)
    end

    it 'sets the current value' do
      expect { posf.set(4) }.not_to raise_error
      expect(posf.buffer[0, 2]).to eq("\004\000")
    end
  end
end
