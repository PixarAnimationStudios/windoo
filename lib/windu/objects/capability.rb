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

  # The class for dealing with the capabilities of Patches in the
  # Title Editor
  #
  # A capability is one criterion, a group of which define which computers
  # are capable of running, and this allowed to install, a Patch.
  class Capability < Windu::BaseClasses::Criterion

    # Mixins
    ######################

    include Windu::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'capabilities'

    CONTAINER_CLASS = Windu::Patch

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute capabilityId
      # @return [Integer] The id number of this capability
      capabilityId: {
        class: :Integer,
        identifier: :primary
      },

      # @!attribute patchId
      # @return [Integer] The id number of the Patch which uses this capability
      patchId: {
        class: :Integer
      }

    }.freeze

    # Public Class Methods
    ######################

    ####
    def self.fetch(*_args)
      raise Windu::UnsupportedError, 'Capabilities are fetched as part of the Patch that contains them'
    end

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response)
      @capabilityId = post_response[:capabilityId]
      @patchId = post_response[:patchId]
      @capabilityId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(_put_response)
      @capabilityId
    end

  end # class Capability

end # Module Windu
