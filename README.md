# Konfigyu

## コンフィギュ

![CircleCI branch](https://img.shields.io/circleci/project/github/bratta/konfigyu/master.svg)
![GitHub](https://img.shields.io/github/license/bratta/konfigyu.svg)
![GitHub issues](https://img.shields.io/github/issues/bratta/konfigyu.svg)
![Gem](https://img.shields.io/gem/v/konfigyu.svg)

When adding an application-specific YAML config file to your project, often you end up writing a bunch
of boilerplate code to manage the file's location, reading in the contents, and managing required values.

This gem strives to make this an easier process to manage so you can start writing your application quicker.
It relies on the sycl and syck gems for loading the yaml.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'konfigyu'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install konfigyu

## Usage

### Basic Usage

Create a YAML config file. For example, `~/konfigyu.yml`

```yaml
foo:
  bar: value
  baz: something-else
log:
  level: info
```

Then, in your code, you can instantiate a new `Konfigyu::Config` object pointing to that file:

```ruby
require 'konfigyu'

config = Konfigyu::Config.new('~/konfigyu.yml')
```

You can access the config values directly, through `data`, or through array `[]` notation:

```ruby
puts config.foo.baz       # Outputs "something-else"
puts config.data.foo.baz  # Outputs "something-else"
puts config['foo.baz']    # Also outputs "something-else"
```

There's a caveat with the dot notation that comes from the way methods are interpreted in ruby. If you have a config tree that is the same name as a reserved word in ruby, eg. `class`, you will have to access it through the array `[]` notation instead of the dot notation.

```yaml
class:
  name: 'Computer Programming'
```

```ruby
puts config.class     # Outputs: Konfigyu::Config
puts config['class']  # Outputs: "Computer Programming"
```

### Required values

You can ensure that certain values are required, and optionally that they contain specific values
by passing in a hash of options to Konfigyu:

```ruby
require 'konfigyu'

config = Konfigyu::Config.new('~/konfigyu.yml' {
  required_fields: ['foo', 'foo.bar', 'log', 'log.level'],
  required_values: { 'log.level': %w[none fatal error warn info debug] }
})
```

Note that if you do not list a field in `required_fields` but include it in `required_values`, it
will stil validate the contents of the field, but only if the field is non-empty.

If validation fails, a `Konfigui::InvalidConfigException` will be raised.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bratta/konfigyu. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Konfigyu project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bratta/konfigyu/blob/master/CODE_OF_CONDUCT.md).
