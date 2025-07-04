require_relative 'bytef_arr'

module Rbzlib
  class Bytef
    def self.new(buffer, offset = 0)
      if buffer.class == Array
        Bytef_arr.new(buffer, offset)
      else
        Bytef_str.new(buffer, offset)
      end
    end
  end
end
