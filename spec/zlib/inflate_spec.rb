# frozen_string_literal: true

########################################################################
# inflate_spec.rb
#
# Spec for the Zlib::Inflate class.
########################################################################
require 'spec_helper'

RSpec.describe Zlib::Inflate do
  let(:inflate) { described_class.new }

  describe 'class methods' do
    it 'responds to inflate_run' do
      expect(described_class).to respond_to(:inflate_run)
    end

    it 'responds to inflate' do
      expect(described_class).to respond_to(:inflate)
    end
  end

  describe 'instance methods' do
    it 'responds to inflate' do
      expect(inflate).to respond_to(:inflate)
    end

    it 'responds to <<' do
      expect(inflate).to respond_to(:<<)
    end

    it 'responds to sync' do
      expect(inflate).to respond_to(:sync)
    end

    it 'responds to sync_point?' do
      expect(inflate).to respond_to(:sync_point?)
    end

    it 'responds to set_dictionary' do
      expect(inflate).to respond_to(:set_dictionary)
    end
  end
end
