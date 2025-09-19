# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

# frozen_string_literal: true

# main module
module Windoo

  # The class for dealing with the criteria of Patch Components
  class ComponentCriterion < Windoo::BaseClasses::Criterion

    # Mixins
    ######################

    include Windoo::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'criteria'

    CONTAINER_CLASS = Windoo::Component

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
    def handle_create_response(post_response, container_id: nil)
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

end # module Windoo
