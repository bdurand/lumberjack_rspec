# Lumberjack RSpec

[![Continuous Integration](https://github.com/bdurand/lumberjack_rspec/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/lumberjack_rspec/actions/workflows/continuous_integration.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/lumberjack_rspec.svg)](https://badge.fury.io/rb/lumberjack_rspec)

This gem provides an RSpec matcher for making assertions about log entries written to a `Lumberjack::Logger` using a `Lumberjack::Device::Test` device.

It allows you to easily verify that specific log entries were created during the execution of your code.

### Why should I test log entries?

Logging is an important part of any server based application, and observability __is__ a product feature.

You don't need to test every log entry. However, where you have important events being logged that impact monitors, metrics, or business decisions, those become critical application functionality. You should be testing that those log entries are created as expected to prevent regressions.

The functionality for testing logs is included in the main [lumberjack](https://github.com/bdurand/lumberjack) gem. This gem provides RSpec syntactic sugar to allow writing more natural tests with better failure messages.

## Usage

### Setup

Require the rspec file in your test helper.

```ruby
require "lumberjack/rspec"
```

In order to use this gem, the logger being tested must be a `Lumberjack::Logger` instance and must use the `Lumberjack::Device::Test` device for output.

```ruby
Application.logger = Lumberjack::Logger.new(:test) # or whatever your application needs to do to set up the logger
```

> [!IMPORTANT]
> You **must** clear logs between tests to avoid false positives since the logger is a persistent shared resource. You can clear the logs by calling `flush`.

You would typically set up clearing the logs in your RSpec configuration with a `before` hook.

```ruby
RSpec.configure do |config|
  config.before do
    Application.logger.flush
  end
end
```

> [!TIP]
> If you are using Rails, then you should use the [lumberjack_rails](https://github.com/bdurand/lumberjack_rails_rspec) gem.
>
> It handles setting up and clearing the logger for you.

### Assertions

You can make assertions about what has been logged using the `include_log_entry` matcher.

```ruby
describe MyClass do
  it "logs information" do
    subject
    expect(Application.logger).to include_log_entry(message: "Something happened")
  end
end
```

You can match on the message, severity, progname, or attributes of a log entry or any combination of thereof.

```ruby
it "logs with attributes" do
  subject
  expect(Application.logger).to include_log_entry(
    severity: :info,
    message: "User logged in",
    attributes: { user_id: 123 }
  )
end
```

You can use regular expressions or RSpec matchers to match any of the fields.

```ruby
it "logs with a regex" do
  subject
  expect(Application.logger).to include_log_entry(
    severity: :error,
    message: /failed/i,
    attributes: { status: be >= 500 }
  )
end
```

You can make assertions on attributes using either a nested hash or a flat hash with dot notation.

```ruby
it "logs with nested attributes" do
  subject
  expect(Application.logger).to include_log_entry(
    message: "Order processed",
    attributes: { order: { id: 456, total: be > 0 } }
  )
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "lumberjack_rspec"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install lumberjack_rspec
```

## Contributing

Open a pull request on GitHub.

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
