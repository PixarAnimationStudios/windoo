# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# frozen_string_literal: true

module Windoo

  class Connection

    # When using included modules to define constants,
    # the constants have to be defined at the level where they will be
    # referenced, or else they
    # aren't available to other broken-out-and-included sub modules
    #
    # See https://cultivatehq.com/posts/ruby-constant-resolution/ for
    # an explanation

    HTTPS_SCHEME = 'https'
    SSL_PORT = 443
    DFT_SSL_VERSION = 'TLSv1_2'

    DFT_OPEN_TIMEOUT = 60
    DFT_TIMEOUT = 60

    # the entire API is at this path
    RSRC_VERSION = 'v2'

    # Only these variables are displayed with PrettyPrint
    # This avoids displaying lots of extraneous data
    PP_VARS = %i[
      @name
      @connected
      @open_timeout
      @timeout
      @connect_time
    ].freeze

    # This module defines constants related to API connctions, used throughout
    # the connection class and elsewhere.
    ##########################################
    module Constants

      def self.included(includer)
        Windoo.verbose_include(includer, self)
      end

    end # module Constants

  end # class Connection

end # module Windoo
