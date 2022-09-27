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

# frozen_string_literal: true

# main module
module Windu

  # The class for dealing with the criteria of Patch Components
  class ComponentCriterion < Windu::BaseClasses::Criterion

    # Mixins
    ######################

    include Windu::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'criteria'

    CONTAINER_CLASS = Windu::Component

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute criteriaId
      # @return [Integer] The id number of this criterion
      criteriaId: {
        class: :Integer,
        identifier: :primary,
        do_not_send: true,
        readonly: true
      },

      # @!attribute componentId
      # @return [Integer] The id number of the component which uses this criterion
      componentId: {
        class: :Integer,
        do_not_send: true,
        readonly: true
      }

    }.freeze

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response)
      @criteriaId = post_response[:criteriaId]
      @componentId = post_response[:componentId]
      @componentId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(_put_response)
      @criteriaIds
    end

  end # class ComponentCriterion

end # module Windu
