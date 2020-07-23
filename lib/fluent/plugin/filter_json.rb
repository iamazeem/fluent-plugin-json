# frozen_string_literal: true

#
# Copyright 2020 Azeem Sajid
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/filter'
require 'hana'

module Fluent
  module Plugin
    # JSON Filter class to override filter method
    class JsonFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter('json', self)

      desc 'The sub-section to specify one check.'
      config_section :check, required: true, multi: true do
        desc 'The JSON pointer to an element.'
        config_param :pointer, :string
        desc 'The regular expression to match the element.'
        config_param :pattern, :regexp
      end

      def configure(conf)
        super

        @check.each do |chk|
          begin
            Hana::Pointer.parse(chk.pointer)
          rescue Hana::Pointer::FormatError => e
            raise Fluent::ConfigError, e
          end
        end
      end

      def filter(_tag, _time, record)
        @check.each do |chk|
          pointer = Hana::Pointer.new(chk.pointer)
          pointee = pointer.eval(record).to_s
          matched = chk.pattern.match(pointee).nil? ? false : true
          log.debug("check: #{matched ? 'pass' : 'fail'} [#{chk.pointer} -> '#{pointee}'] (/#{chk.pattern.source}/)")
          return nil unless matched
        end
        record
      end
    end
  end
end
