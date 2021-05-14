# fluent-plugin-json

[![License: Apache](https://img.shields.io/badge/license-Apache-blue.svg?style=flat-square)](https://github.com/iamAzeem/fluent-plugin-json/blob/master/LICENSE)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/iamAzeem/fluent-plugin-json?style=flat-square)
[![RubyGems Downloads](https://img.shields.io/gem/dt/fluent-plugin-json?color=blue&style=flat-square)](https://rubygems.org/gems/fluent-plugin-json)

![Lines of code](https://img.shields.io/tokei/lines/github/iamAzeem/fluent-plugin-json?label=LOC&style=flat-square)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/iamAzeem/fluent-plugin-json?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/iamAzeem/fluent-plugin-json?style=flat-square)

[Fluentd](https://fluentd.org/) filter plugin for JSON with JSON pointer support
([RFC-6901](https://tools.ietf.org/html/rfc6901)).

## Installation

### RubyGems

```bash
gem install fluent-plugin-json
```

### Bundler

Add the following line to your Gemfile:

```ruby
gem 'fluent-plugin-json'
```

And then execute:

```bash
bundle
```

## Configuration

### `<check>` section (required) (multiple)

* `pointer` (string) (required): The JSON pointer to an element.
* `pattern` (regexp) (required): The regular expression to match the element.

The configuration may consist of one or more checks. Each check contains a
`pointer` to a JSON element and its corresponding `pattern` (regex) to test it.

The checks are evaluated sequentially. The failure of a single check results in
the rejection of the event. A rejected event is not routed for further
processing.

**NOTE**: The JSON element pointed to by the `pointer` is always converted to a
string for testing with the `pattern` (regex).

For the detailed syntax of:

- JSON Pointer, see [RFC-6901](https://tools.ietf.org/html/rfc6901#section-5); and,
- Ruby's Regular Expression, see [Regexp](https://ruby-doc.org/core-2.4.1/Regexp.html).

### Example

Here is a sample configuration with
[`forward`](https://docs.fluentd.org/v/1.0/input/forward) input plugin, `json`
filter plugin with multiple checks and the routing to
[`stdout`](https://docs.fluentd.org/v/1.0/output/stdout) output plugin:

```text
<source>
  @type       forward
  @id         forward_input
</source>

<filter debug.test>
  @type       json
  @id         json_filter

  <check>
    pointer   /log/user     # point to { "log": { "user": "test", ... } }
    pattern   /test/i       # check it against the value of username `test` (ignore case)
  </check>

  <check>
    pointer   /log/codes/0  # point to { "log": { "codes": [123, ...] } }
    pattern   /123/         # check it against the value at 0th index of the codes array i.e. `123`
  </check>

  <check>
    pointer   /log/level    # point to { "log": { "level": "info", ... } }
    pattern   /.*/          # check it against all the log levels
  </check>
</filter>

<match debug.test>
  @type       stdout
</match>
```

For a JSON message:

```json
{ "log": {"user": "test", "codes": [123, 456], "level": "info"} }
```

Sent using `fluent-cat` with tag `debug.test`:

```bash
echo '{ "log": {"user": "test", "codes": [123, 456], "level": "info"} }' | fluent-cat "debug.test"
```

After passing all the checks, the routed event to `stdout` would be:

```bash
2020-07-23 22:36:06.093187459 +0500 debug.test: {"log":{"user":"test","codes":[123,456],"level":"info"}}
```

By default, the checks are logged in `debug` mode only:

```text
2020-07-23 22:47:33 +0500 [debug]: #0 [json_filter] check: pass [/log/user -> 'test'] (/test/)
2020-07-23 22:47:33 +0500 [debug]: #0 [json_filter] check: pass [/log/codes/0 -> '123'] (/123/)
2020-07-23 22:47:33 +0500 [debug]: #0 [json_filter] check: pass [/log/level -> 'info'] (/.*/)
2020-07-23 22:47:33.577900915 +0500 debug.test: {"log":{"user":"test","codes":[123,456],"level":"info"}}
```

## Contribute

- Fork the project.
- Check out the latest `main` branch.
- Create a feature or bugfix branch from `main`.
- Commit and push your changes.
- Make sure to add and run tests locally: `bundle exec rake test`.
- Run `rubocop` locally and fix all the lint warnings.
- Submit the PR.

## License

[Apache 2.0](LICENSE)
