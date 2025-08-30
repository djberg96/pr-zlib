# frozen_string_literal: true

module Zlib
  class Error < StandardError
  end

  class StreamEnd < Error
  end

  class NeedDict < Error
  end

  class DataError < Error
  end

  class StreamError < Error
  end

  class MemError < Error
  end

  class BufError < Error
  end

  class VersionError < Error
  end
end
