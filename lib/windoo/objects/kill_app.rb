# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  # A class representing an Application that cannot be running when
  # a Patch is installed.
  #
  # Patches can contain any number of these, and they are accessed using
  # a {Windoo::KillAppManager} available from the {Patch#killApps} method.
  #
  class KillApp < Windoo::BaseClasses::JSONObject

    # Mixins
    ######################

    include Windoo::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'killapps'

    CONTAINER_CLASS = Windoo::Patch

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute killAppId
      # @return [Integer] The id number of this kill app
      killAppId: {
        class: :Integer,
        identifier: :primary,
        do_not_send: true,
        readonly: true
      },

      # @!attribute patchId
      # @return [Integer] The id number of the patch which uses this
      #   kill app
      patchId: {
        class: :Integer,
        do_not_send: true,
        readonly: true
      },

      # @!attribute bundleId
      # @return [String] The bundle id of the app that must be quit
      #   e.g. com.apple.Safari
      bundleId: {
        class: :String,
        required: true
      },

      # @!attribute appName
      # @return [String] The name of the app that must be quit
      appName: {
        class: :String,
        required: true
      }

    }

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response, container_id: nil)
      @killAppId = post_response[:killAppId]
      @patchId = post_response[:patchId]

      @killAppId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(_put_response)
      @killAppId
    end

  end # class KillApp

end # Module Windoo
