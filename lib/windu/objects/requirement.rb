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

  # The class for dealing with Software Title Requirements in the
  # TitleEditor
  #
  # A requirement is one criterion, a group of which define which computers
  # have the title installed, regardless of version.
  class Requirement < Windu::BaseClasses::Criterion

    # Mixins
    ######################

    include Windu::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'requirements'

    CONTAINER_CLASS = Windu::SoftwareTitle

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute requirementId
      # @return [Integer] The id number of this requirement in the Title Editor
      requirementId: {
        class: :Integer,
        identifier: :primary,
        readonly: true
      },

      # @!attribute softwareTitleId
      # @return [Integer] The id number of the title which uses this requirement
      softwareTitleId: {
        class: :Integer,
        readonly: true
      }

    }.freeze

    # Public Class Methods
    ######################

    ####
    def self.fetch(*_args)
      raise Windu::UnsupportedError, 'Requirements are fetched as part of the SoftwareTitle that contains them'
    end

    # Constructor
    ######################

    def initialize(**init_data)
      super
    end

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response, container_id: nil)
      @requirementId = post_response[:requirementId]
      @absoluteOrderId = post_response[:absoluteOrderId]
      @softwareTitleId = container_id

      @requirementId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(put_response)
      @and_or = put_response[:and] == false ? :or : :and
      @absoluteOrderId = put_response[:absoluteOrderId]

      @requirementId
    end

  end # class Requirement

end # Module Windu
