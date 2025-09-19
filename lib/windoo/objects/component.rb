# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

# frozen_string_literal: true

module Windoo

  # A component holds a bunch of criteria defining which computers
  # have a specific patch version installed.
  class Component < Windoo::BaseClasses::JSONObject

    # Mixins
    ######################

    include Windoo::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'components'

    CONTAINER_CLASS = Windoo::Patch

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute componentId
      # @return [Integer] The id number of this component
      componentId: {
        class: :Integer,
        identifier: :primary,
        do_not_send: true,
        readonly: true
      },

      # @!attribute patchId
      # @return [Integer] The id number of the patch which uses this component
      patchId: {
        class: :Integer,
        do_not_send: true,
        readonly: true
      },

      # @!attribute name
      # @return [String] The name of the Software Title for this patch
      name: {
        class: :String
      },

      # @!attribute version
      # @return [String] The version installed by this patch
      version: {
        class: :String
      },

      # @!attribute criteria
      # @return [Array<Windoo::ComponentCriterion>] The criteria used by
      # this component.
      criteria: {
        class: Windoo::ComponentCriteriaManager,
        do_not_send: true
      }

    }.freeze

    # Constructor
    ######################

    def initialize(**init_data)
      super
      @criteria ||= []
      @criteria = Windoo::ComponentCriteriaManager.new @criteria, container: self
    end

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response, container_id: nil)
      @componentId = post_response[:componentId]
      @patchId = post_response[:patchId]
      @componentId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(_put_response)
      @componentId
    end

  end # class Component

end # Module Windoo
