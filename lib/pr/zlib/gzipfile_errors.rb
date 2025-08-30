# frozen_string_literal: true

require_relative 'errors'

module Zlib
  class GzipFile
    class Error < Zlib::Error
    end

    class NoFooter < Error
    end

    class CRCError < Error
    end

    class LengthError < Error
    end
  end
end
