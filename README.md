# fluent-plugin-json

[Fluentd](https://fluentd.org/) filter plugin for JSON with JSON pointer support
([RFC-6901](https://tools.ietf.org/html/rfc6901)).

## Installation

### RubyGems

```bash
$ gem install fluent-plugin-json
```

### Bundler

Add the following line to your Gemfile:

```ruby
gem "fluent-plugin-json"
```

And then execute:

```bash
$ bundle
```

## Configuration

### `<check>` section (required) (multiple)

* `pointer` (string) (required): The JSON pointer to an element.
* `pattern` (regexp) (required): The regular expression to match the element.

The configuration consists of one or more check(s). Each check contains a
`pointer` to a JSON element and a `pattern` (regex) to test it.

The checks are evaluated sequentially. The failure of a single check results in
rejection of the event. A rejected event is not routed for further processing.

NOTE: The JSON element pointed to by the `pointer` is always converted to string
for testing with the `pattern` (regular expression).

For examples of the syntax of:

- JSON Pointer, see [RFC-6901](https://tools.ietf.org/html/rfc6901#section-5).
- Ruby's Regular Expression, see [Regexp](https://ruby-doc.org/core-2.4.1/Regexp.html).

### Example

Here is a configuration with the input plugin
[`forward`](https://docs.fluentd.org/v/1.0/input/forward), `json` filter plugin
with multiple checks and routing to the output plugin
[`stdout`](https://docs.fluentd.org/v/1.0/output/stdout):

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
    pattern   /test/i       # check it against username `test` (ignore case)
  </check>

  <check>
    pointer   /log/codes/0  # point to { "log": { "codes": [123, ...] } }
    pattern   /123/         # check it against 0th index of codes array
  </check>

  <check>
    pointer   /log/level    # point to { "log": { "level": ... } }
    pattern   /.*/          # check it against all log levels
  </check>
</filter>

<match debug.test>
  @type       stdout
  @id         stdout_output
</match>
```

For a JSON message:

```json
{ "log": {"user": "test", "codes": [123, 456], "level": "info"} }
```

Sent using `fluent-cat` with tag `debug.test`:

```bash
$ echo '{ "log": {"user": "test", "codes": [123, 456], "level": "info"} }' | fluent-cat "debug.test"
```

After passing all the checks, the routed event to `stdout` would be:

```bash
2020-07-23 22:36:06.093187459 +0500 debug.test: {"log":{"user":"test","codes":[123,456],"level":"info"}}
```

By default, the logs for checks are generated in `debug` mode only:

```bash
2020-07-23 22:47:33 +0500 [debug]: #0 [json_filter] check: pass [/log/user -> 'test'] (/test/)
2020-07-23 22:47:33 +0500 [debug]: #0 [json_filter] check: pass [/log/codes/0 -> '123'] (/123/)
2020-07-23 22:47:33 +0500 [debug]: #0 [json_filter] check: pass [/log/level -> 'info'] (/.*/)
2020-07-23 22:47:33.577900915 +0500 debug.test: {"log":{"user":"test","codes":[123,456],"level":"info"}}
```

## Copyright

* Copyright &copy; 2020 [Azeem Sajid](https://www.linkedin.com/in/az33msajid/)
* License
  * Apache License, Version 2.0
