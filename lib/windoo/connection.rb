# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# frozen_string_literal: true

module Windoo

  # Instances of this class represent a connection to a Jamf Title Editor
  class Connection

    # the code for this class is broken into multiple files
    # as modules, to play will with the zeitwerk loader
    include Windoo::Connection::Constants
    include Windoo::Connection::Attributes
    include Windoo::Connection::Connect
    include Windoo::Connection::Actions

    # Constructor
    #####################################

    # Instantiate a connection object.
    #
    # If name: is provided it will be stored as the Connection's name attribute.
    #
    # if no url is provided and params are empty, or contains only
    # a :name key, then you must call #connect with all the connection
    # parameters before accessing a server.
    #
    # See {#connect} for the parameters
    #
    def initialize(url = nil, **params)
      @name = params.delete :name
      @connected = false

      return if url.nil? && params.empty?

      connect url, **params
    end # init

    # Instance methods
    #####################################

    # A useful string about this connection
    #
    # @return [String]
    #
    def to_s
      return 'not connected' unless connected?

      if name.to_s.start_with? "#{user}@"
        name
      else
        "#{user}@#{host}:#{port}, name: #{name}"
      end
    end

    # Only selected items are displayed with prettyprint
    # otherwise its too much data in irb.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      PP_VARS
    end

    # @deprecated, use .token.next_refresh
    def next_refresh
      @token.next_refresh
    end

    # @deprecated, use .token.secs_to_refresh
    def secs_to_refresh
      @token.secs_to_refresh
    end

    # @deprecated, use .token.time_to_refresh
    def time_to_refresh
      @token.time_to_refresh
    end

    # is this the default connection?
    def default?
      self == Windoo.cnx
    end

  end # class Connection

end # module Windoo
