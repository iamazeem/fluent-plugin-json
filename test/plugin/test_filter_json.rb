# frozen_string_literal: true

require 'helper'
require 'fluent/plugin/filter_json.rb'

class JsonFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test 'failure' do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::JsonFilter).configure(conf)
  end
end
