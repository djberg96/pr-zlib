# RSpec Tests for pr-zlib

This directory contains RSpec specifications for the pr-zlib library, converted from the original test-unit tests.

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run tests via rake
bundle exec rake spec

# Run specific test file
bundle exec rspec spec/zlib_spec.rb

# Run with documentation format
bundle exec rspec --format documentation
```

## Test Structure

- `spec_helper.rb` - Common RSpec configuration
- `zlib_spec.rb` - Tests for the main Zlib module
- `rbzlib_spec.rb` - Tests for the Rbzlib module
- `rbzlib_bytef_spec.rb` - Tests for Rbzlib::Bytef class
- `rbzlib_posf_spec.rb` - Tests for Rbzlib::Posf class
- `zlib/` - Directory containing tests for Zlib subclasses
  - `deflate_spec.rb` - Tests for Zlib::Deflate
  - `inflate_spec.rb` - Tests for Zlib::Inflate
  - `zstream_spec.rb` - Tests for Zlib::ZStream
  - `gzip_file_spec.rb` - Tests for Zlib::GzipFile
  - `gzip_reader_spec.rb` - Basic tests for Zlib::GzipReader
  - `gzip_writer_spec.rb` - Basic tests for Zlib::GzipWriter

## Conversion Notes

The tests were converted from test-unit to RSpec format with the following changes:

- `assert_equal(expected, actual)` → `expect(actual).to eq(expected)`
- `assert_respond_to(object, method)` → `expect(object).to respond_to(method)`
- `assert_raise(exception)` → `expect { }.to raise_error(exception)`
- `assert_not_nil(value)` → `expect(value).not_to be_nil`
- `assert_nothing_raised` → `expect { }.not_to raise_error`

The basic interface tests have been preserved, though some complex file I/O tests for GzipReader and GzipWriter have been simplified to focus on the core interface verification.
