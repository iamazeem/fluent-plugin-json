# fluent-plugin-json

[![ci](https://github.com/iamazeem/fluent-plugin-json/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iamazeem/fluent-plugin-json/actions/workflows/ci.yml)
[![License: Apache](https://img.shields.io/badge/license-Apache-blue.svg?style=flat-square)](https://github.com/iamAzeem/fluent-plugin-json/blob/master/LICENSE)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/iamAzeem/fluent-plugin-json?style=flat-square)
[![RubyGems Downloads](https://img.shields.io/gem/dt/fluent-plugin-json?color=blue&style=flat-square)](https://rubygems.org/gems/fluent-plugin-json)

![Lines of code](https://img.shields.io/tokei/lines/github/iamAzeem/fluent-plugin-json?label=LOC&style=flat-square)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/iamAzeem/fluent-plugin-json?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/iamAzeem/fluent-plugin-json?style=flat-square)

- [Overview](#overview)
- [Installation](#installation)
  - [RubyGems](#rubygems)
  - [Bundler](#bundler)
- [Configuration](#configuration)
  - [`<check>` section (required) (multiple)](#check-section-required-multiple)
  - [Example](#example)
- [Contribute](#contribute)
- [License](#license)

## Overview

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

- `pointer` (string) (required): The JSON pointer to an element.
- `pattern` (regexp) (required): The regular expression to match the element.
- `negate` (Boolean) (optional): Negate the result of match.

The configuration may consist of one or more checks. Each check contains a
`pointer` to a JSON element and its corresponding `pattern` (regex) to test it.

The checks are evaluated sequentially. The failure of a single check results in
the rejection of the whole event. A rejected event is not routed for further
processing.

The `negate` flag negates the result of a `check`. It's pretty handy to revert
the result instead of fiddling with the regex with negative lookahead (`?!`) and
inversion (`^`).

**NOTE**: The JSON element pointed to by the `pointer` is always converted to a
string for testing with the `pattern` (regex).

For the detailed syntax of:

- JSON Pointer, see [RFC-6901](https://tools.ietf.org/html/rfc6901#section-5); and,
- Ruby's Regular Expression, see [Regexp](https://ruby-doc.org/core-2.4.1/Regexp.html).

### Example

For a JSON message:

```json
{ "log": { "user": "test", "codes": [123, 456], "level": "info", "msg": "Sample message!" } }
```

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
    pattern   /info/        # check it against log level `info`
  </check>

  <check>
    pointer   /log/msg      # point to { "log": { "msg": "..." } }
    pattern   /exception/i  # check it against `exception` (ignore case)
    negate    true          # negate the match i.e. `msg` does not contain `exception`
  </check>
</filter>

<match debug.test>
  @type       stdout
</match>
```

Send JSON log message using `fluent-cat` with tag `debug.test`:

```bash
echo '{ "log": { "user": "test", "codes": [123, 456], "level": "info", "msg": "Sample message!" } }' | fluent-cat 'debug.test'
```

After passing all the checks, the routed event to `stdout` would be:

```bash
2022-01-09 14:46:38.008578822 +0500 debug.test: {"log":{"user":"test","codes":[123,456],"level":"info","msg":"Sample message!"}}
```

By default, the checks are logged in `debug` mode only:

```text
2022-01-09 15:24:10 +0500 [debug]: #0 [json_filter] check: pass [/log/user ('test') =~ /test/]
2022-01-09 15:24:10 +0500 [debug]: #0 [json_filter] check: pass [/log/codes/0 ('123') =~ /123/]
2022-01-09 15:24:10 +0500 [debug]: #0 [json_filter] check: pass [/log/level ('info') =~ /info/]
2022-01-09 15:24:10 +0500 [debug]: #0 [json_filter] check: pass [/log/msg ('Sample message!') !~ /exception/]
2022-01-09 15:24:10.696222019 +0500 debug.test: {"log":{"user":"test","codes":[123,456],"level":"info","msg":"Sample message!"}}
```

The symbols `=~` and `!~` in the logs denote match and mismatch (negation)
respectively.

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
