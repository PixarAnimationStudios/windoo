# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

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
