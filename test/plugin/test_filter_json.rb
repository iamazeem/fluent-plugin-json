# frozen_string_literal: true

require 'helper'
require 'fluent/plugin/filter_json'

class JsonFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    @time = event_time
  end

  def create_driver(conf = '')
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::JsonFilter).configure(conf)
  end

  sub_test_case 'configure' do
    test 'test required section <check>' do
      assert_raise(NameError) do
        create_driver(conf)
      end
    end

    test 'test required parameters' do
      conf = %(
        <check>
        </check>
      )
      assert_raise(Fluent::ConfigError) do
        create_driver(conf)
      end
    end

    test 'test single check' do
      conf = %(
        <check>
          pointer   /test/
          pattern   /.*/
        </check>
      )
      d = create_driver(conf)
      assert_equal(1, d.instance.check.length)
    end

    test 'test multiple checks' do
      conf = %(
        <check>
          pointer   /test/
          pattern   /.*/
        </check>
        <check>
          pointer   /test/
          pattern   /.*/
        </check>
      )
      d = create_driver(conf)
      assert_equal(2, d.instance.check.length)
    end

    test 'test invalid pointer (JSON pointer should start with a slash)' do
      conf = %(
        <check>
          pointer   .
          pattern   /.*/
        </check>
      )
      assert_raise(Fluent::ConfigError) do
        create_driver(conf)
      end
    end
  end

  sub_test_case 'filter' do
    def records
      [
        { 'log' => { 'user' => 'test', 'codes' => [123, 456], 'level' => 'info' } }
      ]
    end

    def filter(conf, records)
      d = create_driver(conf)
      d.run do
        records.each do |record|
          d.feed('filter.test', @time, record)
        end
      end
      d.filtered_records
    end

    test 'test multiple checks' do
      conf = %(
        <check>
          pointer   /log/user
          pattern   /test/i
        </check>

        <check>
          pointer   /log/codes/0
          pattern   /123/
        </check>

        <check>
          pointer   /log/level
          pattern   /.*/
        </check>
      )
      filtered_records = filter(conf, records)
      assert_equal(records.values_at(0), filtered_records)
    end
  end
end
