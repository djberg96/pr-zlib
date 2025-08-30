# frozen_string_literal: true

########################################################################
# deflate_spec.rb
#
# Spec for the Zlib::Deflate class.
########################################################################
require 'spec_helper'

RSpec.describe Zlib::Deflate do
  let(:deflate) { described_class.new }

  describe 'class methods' do
    it 'responds to deflate_run' do
      expect(described_class).to respond_to(:deflate_run)
    end

    it 'responds to deflate' do
      expect(described_class).to respond_to(:deflate)
    end
  end

  describe 'instance methods' do
    it 'responds to deflate' do
      expect(deflate).to respond_to(:deflate)
    end

    it 'responds to <<' do
      expect(deflate).to respond_to(:<<)
    end

    it 'responds to flush' do
      expect(deflate).to respond_to(:flush)
    end

    it 'responds to params' do
      expect(deflate).to respond_to(:params)
    end

    it 'responds to set_dictionary' do
      expect(deflate).to respond_to(:set_dictionary)
    end
  end
end
