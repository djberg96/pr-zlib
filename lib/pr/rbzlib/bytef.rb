# frozen_string_literal: true

require_relative 'byte_buffer'

module Rbzlib
  class Bytef
    def self.new(buffer, offset = 0)
      Rbzlib.create_buffer(buffer, offset)
    end
  end
end
