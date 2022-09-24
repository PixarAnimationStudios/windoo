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
#

module Windu

  # The class for dealing with Software Title ExtensionAttributes in the
  # TitleEditor
  #
  # NOTE: All interaction with these should usually be via the
  # SoftwareTitle instance methods:
  #
  #   SoftwareTitle#extensionAttribute
  #   SoftwareTitle#add_extensionAttribute
  #   SoftwareTitle#update_extensionAttribute
  #   SoftwareTitle#delete_extensionAttribute
  #
  class ExtensionAttribute < Windu::BaseClasses::JSONObject

    # Mixins
    ######################

    include Windu::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'extensionattributes'

    CONTAINER_CLASS = Windu::SoftwareTitle

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute extensionAttributeId
      # @return [Integer] The id number of this extension attribute in the Title Editor
      extensionAttributeId: {
        class: :Integer,
        identifier: :primary
      },

      # @!attribute softwareTitleId
      # @return [Integer] The id number of the title which uses this extension attribute
      softwareTitleId: {
        class: :Integer
      },

      # @!attribute key
      # @return [String] The name of the extension attribute as it appears in Jamf Pro
      #    NOTE: must be unique in the Title Editor AND Jamf Pro.
      key: {
        class: :String,
        required: true,
        identifier: true
      },

      # @!attribute value
      # @return [String] The Base64 encoded script for this extension attribute
      value: {
        class: :String
      },

      # @!attribute displayName
      # @return [String] The name of the extension attribute as it appears in Title Editor
      displayName: {
        class: :String,
        required: true
      }

    }.freeze

    # Construcor
    ######################
    def initialize(**init_data)
      super
      self.script = @init_data[:script] if @init_data[:script]
    end

    # Public Instance Methods
    ######################

    # @return [String] The script code for this extension attribute
    def script
      return if value.to_s.empty?

      require 'base64'
      Base64.decode64 value
    end

    # @param code [String] The script code for this extension attribute
    # @return [void]
    def script=(code)
      raise ArgumentError, 'Code must be a string starting with #!' unless code.to_s.start_with?('#!')

      require 'base64'
      self.value = Base64.encode64(code)
    end

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response, container_id: nil)
      @extensionAttributeId = post_response[:extensionAttributeId]
      @softwareTitleId = container_id
      @extensionAttributeId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(_put_response)
      @extensionAttributeId
    end

  end # class ExtensionAttribute

end # module Windu
