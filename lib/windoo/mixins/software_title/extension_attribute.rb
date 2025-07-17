# Copyright 2025 Pixar
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
#

# frozen_string_literal: true

module Windoo

  module Mixins

    module SoftwareTitle

      # An module that manages the ExtensionAttribute in a
      # SoftwareTitle.
      #
      # Even though 'extensionAttributes' is plural, and
      # they come from the server in an Array, at the moment there
      # can only be one per SoftwareTitle.
      #
      # This module hides that confusion and allows you to work with
      # just one
      #
      # If there's already an extension attribute, you can access it
      # from the #extensionAttribute getter, and use that to directly
      # update its values.
      #
      module ExtensionAttribute

        # Construcor
        ######################
        def initialize(**init_data)
          super
          @extensionAttribute =
            if @init_data[:extensionAttributes]&.first
              Windoo::ExtensionAttribute.instantiate_from_container(
                container: self,
                **@init_data[:extensionAttributes].first
              )
            end
        end

        # Public Instance Methods
        ####################################

        # Add an ExtensionAttribute to this SoftwareTitle.
        #
        # NOTE: There can be only one EA per SoftwareTitle. You will
        # get an error if one already exists.
        #
        # @param key [String] The name of the extension attribute as
        #   it appears in Jamf Pro
        #   NOTE: must be unique in the Title Editor AND Jamf Pro.
        #
        # @param displayName [String] The name of the extension
        #   attribute as it appears in Title Editor
        #
        # @param script [String] The script of that returns
        #   the value of the Extension Attribute on a computer.
        #   It must be a String that starts with '#!'
        #
        # @return [Integer] The id of the new Extension Attribute
        #
        def add_extensionAttribute(key:, displayName:, script:)
          if @extensionAttribute
            raise Windoo::AlreadyExistsError,
                  'This SoftwareTitle already has an Extension Attribute. Either delete it before creating a new one, or update the existing one.'
          end

          @extensionAttribute = Windoo::ExtensionAttribute.create(
            container: self,
            key: key,
            displayName: displayName,
            script: script
          )

          @extensionAttribute.extensionAttributeId
        end

        # Delete the ExtensionAttribute from this SoftwareTitle
        #
        # When deleting an EA via this method, it is deleted
        # from the server immediately, there is no need to #save
        # the SoftwareTitle
        #
        # @return [Integer] The id of the deleted Extension Attribute
        #
        def delete_extensionAttribute
          return unless @extensionAttribute

          deleted_id = @extensionAttribute.delete
          @extensionAttribute = nil

          deleted_id
        rescue Windoo::NoSuchItemError
          nil
        end

      end # module ExtensionAttribute

    end # module SoftwareTitle

  end # module Mixins

end # module Windoo
