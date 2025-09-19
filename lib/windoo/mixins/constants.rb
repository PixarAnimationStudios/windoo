# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

# frozen_string_literal: true

module Windoo

  # When using included modules to define constants,
  # the constants have to be defined at the level where they will be
  # referenced, or else they
  # aren't available to other broken-out-and-included sub modules
  #
  # See https://cultivatehq.com/posts/ruby-constant-resolution/ for
  # an explanation

  # The minimum Ruby version needed for windoo
  MINIMUM_RUBY_VERSION = '2.6.3'

  # These are handy for testing values without making new arrays, strings, etc every time.
  TRUE_FALSE = [true, false].freeze

  # Empty strings are used in various places
  BLANK = ''

  module Mixins

    # Constants useful throughout Windoo
    # This should be included into the Jamf module
    #####################################
    module Constants

      # when this module is included, also extend our Class Methods
      def self.included(includer)
        Windoo.load_msg "--> #{includer} is including Windoo::Constants"
      end

    end # module constants

  end #  module Mixins

end # module Windoo
