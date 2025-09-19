# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  module Mixins

    module Patch

      # An module that manages the Component in a
      # Patch.
      #
      # Even though 'components' is plural, and
      # they come from the server in an Array, at the moment there
      # can only be one per Paatch.
      #
      # This module hides that confusion and allows you to work with
      # just one
      #
      # If there's already an component, you can access it
      # from the #component getter, and use that to directly
      # update its values.
      #
      module Component

        # Construcor
        ######################
        def initialize(**init_data)
          super
          @component =
            if @init_data[:components]&.first
              Windoo::Component.instantiate_from_container(
                container: self,
                **@init_data[:components].first
              )
            end
        end

        # Public Instance Methods
        ####################################

        # Add a component to this Patch. After its created,
        # you can add criteria to it.
        #
        # NOTE: There can be only one per v. You will
        # get an error if one already exists.
        #
        # @param name [String] The name of the component. Usually
        #   the same as the name of the Software Title it is
        #   associated with
        #
        # @param version [String] The version of the componen.
        #   Usually the same as the version of the Patch if it
        #   associated with
        #
        # @return [Integer] The id of the new Extension Attribute
        #
        def add_component(name:, version:)
          if @component
            raise Windoo::AlreadyExistsError,
                  'This Patch already has a Component. Either delete it before creating a new one, or update the existing one.'
          end

          @component = Windoo::Component.create(
            container: self,
            cnx: cnx,
            name: name,
            version: version
          )

          @component.componentId
        end

        # Delete the component from this Patch
        #
        # @return [Integer] The id of the deleted Extension Attribute
        #
        def delete_component
          return unless @component

          deleted_id = @component.delete
          @component = nil

          # patches without a component are not valid
          # so must be disabled
          container.disable

          deleted_id
        end

      end # module ExtensionAttribute

    end # module SoftwareTitle

  end # module Mixins

end # module Windoo
