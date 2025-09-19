# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# frozen_string_literal: true

module Windoo

  module Mixins

    # Module methods and aliases for dealing with the default connection
    # This is extended into the API module
    ######################
    module DefaultConnection

      # When this module is extended into a class
      def self.extended(extender)
        Windoo.verbose_extend extender, self
      end

      # The current default Windoo::Connection instance.
      #
      # @return [Windoo::Connection]
      #
      def default_connection
        @default_connection ||= Windoo::Connection.new name: :default
      end
      alias cnx default_connection

      # Create a new Connection object and use it as the default for all
      # future API calls. This will replace the existing default connection with
      # a totally new one
      #
      # @param (See Windoo::Connection#initialize)
      #
      # @return [String] the to_s output of the new connection
      #
      def connect(url = nil, **params)
        params[:name] ||= :default
        @default_connection = Windoo::Connection.new url, **params
        @default_connection.to_s
      end
      alias login connect

      # Use the given Windoo::Connection object as the default connection, replacing
      # the one that currently exists.
      #
      # @param connection [Windoo::Connection] The default Connection to use for future
      #   API calls
      #
      # @return [APIConnection] The connection now being used.
      #
      def cnx=(connection)
        unless connection.is_a? Windoo::Connection
          raise 'Title Editor connections must be instances of Windoo::Connection'
        end

        @default_connection = connection
      end

      # Disconnect the default connection
      #
      def disconnect
        @default_connection.disconnect if @default_connection&.connected?
      end
      alias logout disconnect

    end # module DefaultConnection

  end #   module Mixins

end # module Windoo
