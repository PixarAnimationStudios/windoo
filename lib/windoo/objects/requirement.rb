# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  # The class for dealing with Software Title Requirements in the
  # TitleEditor
  #
  # A requirement is one criterion, a group of which define which computers
  # have the title installed, regardless of version.
  class Requirement < Windoo::BaseClasses::Criterion

    # Mixins
    ######################

    include Windoo::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'requirements'

    CONTAINER_CLASS = Windoo::SoftwareTitle

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
      raise Windoo::UnsupportedError, 'Requirements are fetched as part of the SoftwareTitle that contains them'
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

end # Module Windoo
