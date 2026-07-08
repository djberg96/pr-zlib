require 'pr/zlib'
require_relative 'support'

FILE_NAME = 'zlib_temp.txt'
GZ_FILE_NAME = 'zlib_temp.txt.gz'
LINES = ProfileSupport.env_int('PROFILE_LINES', ProfileSupport::DEFAULT_PROFILE_LINES)
ITERATIONS = ProfileSupport.env_int('PROFILE_ITERATIONS', ProfileSupport::DEFAULT_PROFILE_ITERATIONS)

ProfileSupport.create_text_file(FILE_NAME, lines: LINES)
input = File.binread(FILE_NAME)
ProfileSupport.report_config(
  'Profiling pr-zlib write',
  iterations: ITERATIONS,
  lines: LINES,
  file: FILE_NAME
)

require 'ruby-prof'

result = RubyProf::Profile.profile do
  ITERATIONS.times do
    Zlib::GzipWriter.open(GZ_FILE_NAME) do |gz|
      gz.write(input)
    end
  end
end

ProfileSupport.cleanup(FILE_NAME, GZ_FILE_NAME)

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
