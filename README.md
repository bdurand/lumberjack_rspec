# Lumberjack RSpec

[![Continuous Integration](https://github.com/bdurand/lumberjack_rspec/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/lumberjack_rspec/actions/workflows/continuous_integration.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/lumberjack_rspec.svg)](https://badge.fury.io/rb/lumberjack_rspec)

TODO: describe the gem

## Usage

You can include some RSpec syntactic sugar by requiring the rspec file in your test helper.

```ruby
require "lumberjack/rspec"
```

This will give you an `include_log_entry` matcher. The `include_log_entry` matcher provides a bit cleaner output which can make debugging failing tests a bit easier.

```ruby
describe MyClass do
  it "logs information" do
    subject
    expect(Application.logger).to include_log_entry(message: "Something")
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lumberjack_rspec'
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
