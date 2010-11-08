require 'pr/zlib'

FILE_NAME = 'zlib_temp.txt'
GZ_FILE_NAME = 'zlib_temp.txt.gz'

# Create a text file to use first.
File.open(FILE_NAME, "w") do |fh|
  1000.times{ |x|
    s = "Now is the time for #{x} good men to come to the aid of their country."
    fh.puts s
  }
end

require 'profile'

Zlib::GzipReader.open(GZ_FILE_NAME) do |gz|
  gz.read
end
