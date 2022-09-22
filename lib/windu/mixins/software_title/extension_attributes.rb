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
#

# frozen_string_literal: true

module Windu

  module Mixins

    module SoftwareTitle

      # Methods to mix in to the SoftwareTitle class,
      # relating to ExtensionAttributes
      #
      # NOTE: Even though 'extensionAttributes' is plural, and
      # they come from the server in an Array, at the moment there
      # can only be one per SoftwareTitle.
      #
      module ExtensionAttributes

        def self.included(includer)
          Windu.verbose_include includer, self
        end

        # Public Instance Methods
        ####################################

        # Simpler access to the one allowed
        # ExtensionAttribute.
        def extensionAttribute
          @extensionAttributes.first
        end

        # Add an ExtensionAttribute to this SoftwareTitle.
        #
        # When adding the EA via this method, it is added
        # immediately to the server, there is no need to #save
        # the SoftwareTitle
        #
        # NOTE: There can be only one EA per SoftwareTitle
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
          unless @extensionAttributes.empty?
            raise Windu::UnsupportedError,
                  'There can only be one ExtensionAttribute per SoftwareTitle'
          end

          new_ea = Windu::ExtensionAttribute.create(
            key: key,
            displayName: displayName,
            script: script
          )

          ea_id = new_ea.save container_id: primary_id
          @lastModified = Time.now.utc

          @extensionAttributes << new_ea
          ea_id
        end

        # Update the ExtensionAttribute in this SoftwareTitle.
        #
        # When updating the EA via this method, it is updated
        # immediately to the server, there is no need to #save
        # the SoftwareTitle
        #
        # @param key [String] A new name for the extension attribute as
        #   it appears in Jamf Pro. If nil, the key is not updated.
        #   NOTE: must be unique in the Title Editor AND Jamf Pro.
        #
        # @param displayName [String] A new name of the extension
        #   attribute as it appears in Title Editor. If nil, the
        #   displayName is not updated.
        #
        # @param script [String] The script of that returns
        #   the value of the Extension Attribute on a computer.
        #   It must be a String that starts with '#!'. If nil,
        #   the script is not updated.
        #
        # @return [Integer] The id of the new Extension Attribute
        #
        def update_extensionAttribute(key: nil, displayName: nil, script: nil)
          unless extensionAttribute
            raise Windu::NoSuchItemError,
                  "This SoftwareTitle doesn't have an ExtensionAttribute yet. Use #add_extension_attribute}"
          end

          extensionAttribute.script = script if script
          extensionAttribute.key = key if key
          extensionAttribute.displayName = displayName if displayName

          extensionAttribute.save
          @lastModified = Time.now.utc

          extensionAttribute.extensionAttributeId
        end

        # Delete the ExtensionAttribute from this SoftwareTitle
        # by its id or key, one of which must be provided.
        #
        # When deleting an EA via this method, it is deleted
        # from the server immediately, there is no need to #save
        # the SoftwareTitle
        #
        # @return [Integer] The id of the deleted Extension Attribute
        #
        def delete_extensionAttribute
          return unless extensionAttribute

          deleted_id = extensionAttribute.delete
          @lastModified = Time.now.utc

          @extensionAttributes = []

          deleted_id
        end

        # Private Instance Methods
        ##################################

        # Given an id or a key, find the matching EA in this SoftwareTitle,
        # and return it.
        #
        # Raises an exception if not found.
        #
        # NOTE: Even though there can be only one EA, I'm leaving this code here
        # in case multiple's are allowed in the future.
        #
        # @param ident [String, Integer] the ID or Key of an EA contained in
        #   this SoftwareTitle.
        #
        # @return [Windu::ExtensionAttribute] the valid ID of the matching EA
        #
        # def find_ea(ident)
        #   idx = @extensionAttributes.index { |ea| ea.extensionAttributeId == ident || ea.key == ident }
        #   raise Windu::NoSuchItemError, 'No matching ExtensionAttribute in this SoftwareTitle' unless idx

        #   @extensionAttributes[idx]
        # end

      end # module ExtensionAttribute

    end # module SoftwareTitle

  end # module Mixins

end # module Windu
