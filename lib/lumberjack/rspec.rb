# frozen_string_literal: true

require "lumberjack"

# RSpec helper methods for working with Lumberjack loggers.
module Lumberjack::RSpec
  VERSION = File.read(File.expand_path("../../VERSION", __dir__)).strip.freeze

  # Create a matcher for checking if a log entry is included in the logs.
  # This matcher provides better error messages than using the include? method directly.
  #
  # @param expected_hash [Hash] The expected log entry attributes to match.
  # @option expected_hash [String, Regexp] :message The expected message content.
  # @option expected_hash [Hash] :attributes Expected log entry attributes.
  # @option expected_hash [String] :progname Expected program name.
  # @return [Lumberjack::RSpec::IncludeLogEntryMatcher] A matcher for the expected log entry.
  # @example
  #   expect(logs).to include_log_entry(severity: :info, message: "User logged in")
  # @example
  #   expect(logs).to include_log_entry(message: /error/i, attributes: {user_id: 123})
  def include_log_entry(expected_hash)
    Lumberjack::RSpec::IncludeLogEntryMatcher.new(expected_hash)
  end
end

require_relative "rspec/include_log_entry_matcher"

::RSpec.configure do |config|
  config.include Lumberjack::RSpec
end
