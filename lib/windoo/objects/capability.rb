# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  # The class for dealing with the capabilities of Patches in the
  # Title Editor
  #
  # A capability is one criterion, a group of which define which computers
  # are capable of running, and this allowed to install, a Patch.
  class Capability < Windoo::BaseClasses::Criterion

    # Mixins
    ######################

    include Windoo::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'capabilities'

    CONTAINER_CLASS = Windoo::Patch

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute capabilityId
      # @return [Integer] The id number of this capability
      capabilityId: {
        class: :Integer,
        identifier: :primary,
        do_not_send: true,
        readonly: true
      },

      # @!attribute patchId
      # @return [Integer] The id number of the Patch which uses this capability
      patchId: {
        class: :Integer,
        do_not_send: true,
        readonly: true
      }

    }.freeze

    # Public Class Methods
    ######################

    ####
    def self.fetch(*_args)
      raise Windoo::UnsupportedError, 'Capabilities are fetched as part of the Patch that contains them'
    end

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response, container_id: nil)
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

end # Module Windoo
