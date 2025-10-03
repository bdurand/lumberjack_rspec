# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lumberjack::RSpec do
  let(:logger) { Lumberjack::Logger.new(:test) }

  describe "VERSION" do
    it "has a version number" do
      expect(Lumberjack::RSpec::VERSION).not_to be nil
    end
  end

  describe "include_log_entry matcher" do
    it "matches when the expected log entry exists" do
      logger.info("test message")
      logger.error("error occurred")

      expect(logger).to include_log_entry(severity: :info, message: "test message")
      expect(logger).to include_log_entry(severity: :error, message: "error occurred")
    end

    it "matches using RSpec matchers in expectation values" do
      logger.info("checkout complete", amount: 49.99, items: [3, 2, 1])

      expect(logger).to include_log_entry(
        message: kind_of(String),
        attributes: {amount: be > 40, items: match_array([1, 2, 3])}
      )
    end

    it "does not match when the expected log entry does not exist" do
      logger.info("test message")

      expect(logger).not_to include_log_entry(severity: :error, message: "test message")
      expect(logger).not_to include_log_entry(severity: :info, message: "different message")
    end

    it "matches with partial criteria" do
      logger.warn("warning message", user_id: 123, action: "login")

      expect(logger).to include_log_entry(severity: :warn)
      expect(logger).to include_log_entry(message: "warning message")
      expect(logger).to include_log_entry(message: /warning/)
      expect(logger).to include_log_entry(attributes: {user_id: 123})
      expect(logger).to include_log_entry(attributes: {action: "login"})
    end

    it "matches with regular expressions" do
      logger.info("User 123 logged in successfully")

      expect(logger).to include_log_entry(severity: :info, message: /User \d+ logged in/)
      expect(logger).not_to include_log_entry(severity: :info, message: /User \d+ logged out/)
    end

    it "matches with complex attribute structures" do
      logger.info("complex log", user: {id: 123, name: "John"}, metadata: {version: "1.0", features: ["auth", "logging"]})

      expect(logger).to include_log_entry(attributes: {user: {id: 123}})
      expect(logger).to include_log_entry(attributes: {"user.id" => 123})
      expect(logger).to include_log_entry(attributes: {metadata: {version: "1.0"}})
      expect(logger).not_to include_log_entry(attributes: {user: {id: 456}})
    end

    it "matches with progname" do
      logger.progname = "TestApp"
      logger.info("application started")

      expect(logger).to include_log_entry(severity: :info, progname: "TestApp")
      expect(logger).to include_log_entry(progname: /Test/)
      expect(logger).not_to include_log_entry(progname: "DifferentApp")
      expect(logger).to include_log_entry(progname: kind_of(String))
    end

    it "provides clear failure messages" do
      logger.info("actual message")

      expect {
        expect(logger).to include_log_entry(severity: :info, message: "expected message")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError) do |error|
        expect(error.message).to include("expected logs to include entry")
        expect(error.message).to include("expected message")
        expect(error.message).to include("Logged 1 entry")
        expect(error.message).to include("actual message")
      end
    end

    it "provides clear failure messages for negated expectations" do
      logger.info("test message")

      expect {
        expect(logger).not_to include_log_entry(severity: :info, message: "test message")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    describe "using a test device" do
      it "works with a Lumberjack::Device::Test directly" do
        device = Lumberjack::Device::Test.new
        logger.device = device

        logger.info("test message")

        expect(device).to include_log_entry(severity: :info, message: "test message")
        expect(device).not_to include_log_entry(severity: :error)
      end
    end

    describe "edge cases and error handling" do
      it "handles invalid objects gracefully" do
        expect {
          expect("not a logger").to include_log_entry(severity: :info, message: "test")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError) do |error|
          expect(error.message).to include("Expected a Lumberjack::Logger object, but received a String")
        end
      end

      it "handles nil logger gracefully" do
        expect {
          expect(nil).to include_log_entry(severity: :info, message: "test")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError) do |error|
          expect(error.message).to include("Expected a Lumberjack::Logger object, but received a NilClass")
        end
      end

      it "works with matchers in expectation values" do
        logger.info("test message")

        expect(logger).to include_log_entry(severity: :info, message: instance_of(String))
        expect(logger).to include_log_entry(severity: :info, message: a_string_matching(/test/))
        expect(logger).not_to include_log_entry(severity: :info, message: instance_of(Integer))
      end
    end

    describe "integration with RSpec features" do
      it "provides proper description for test documentation" do
        matcher = include_log_entry(severity: :info, message: "test")
        expect(matcher.description).to eq("have logged entry with severity: :info, message: \"test\"")
      end
    end
  end
end
