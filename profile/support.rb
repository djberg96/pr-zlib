# frozen_string_literal: true

module ProfileSupport
  DEFAULT_BENCH_LINES = 100_000
  DEFAULT_PROFILE_LINES = 10_000
  DEFAULT_PROFILE_ITERATIONS = 3

  module_function

  def env_int(name, default)
    value = ENV[name]
    return default if value.nil? || value.empty?

    Integer(value)
  rescue ArgumentError
    warn "Ignoring invalid #{name}=#{value.inspect}; using #{default}"
    default
  end

  def create_text_file(path, lines: DEFAULT_LINES)
    File.open(path, 'wb') do |fh|
      lines.times do |x|
        fh.puts "Now is the time for #{x} good men to come to the aid of their country."
      end
    end
  end

  def file_size(path)
    File.size(path)
  end

  def format_bytes(bytes)
    units = %w[B KB MB GB]
    size = bytes.to_f
    unit = units.shift

    while size >= 1024 && !units.empty?
      size /= 1024
      unit = units.shift
    end

    format('%.2f %s', size, unit)
  end

  def cleanup(*paths)
    paths.each do |path|
      File.delete(path) if File.exist?(path)
    end
  end

  def report_config(title, iterations:, lines:, file:)
    puts
    puts "== #{title} =="
    puts "iterations: #{iterations}"
    puts "lines:      #{lines}"
    puts "input:      #{format_bytes(file_size(file))}"
    puts
  end
end
