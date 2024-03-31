# Copyright 2022 Pixar
#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.

# frozen_string_literal: true

module Windoo

  # Methods for converting values in standard ways
  # Usually used for converting between Ruby values and JSON values
  # between Windoo and the Server
  module Converters

    # @param time [Time] a Time object to send to the API
    # @return [String] The time in UTC and ISO8601 format
    def self.time_to_api(time)
      time.utc.iso8601
    end

    # @param time [#to_s] a timestamp from the API
    # @return [Time] The timestamp as a Time object
    def self.to_time(time)
      return time if time.is_a? Time

      Time.parse time.to_s
    end

  end # Utility

end # Windoo
