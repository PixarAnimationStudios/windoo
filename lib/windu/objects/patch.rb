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

module Windu

  # A patch represents a specific version of a Software Title.
  class Patch < Windu::BaseClasses::JSONObject

    # Mixins
    ######################

    include Windu::Mixins::APICollection
    include Windu::Mixins::Patch::Component

    # Constants
    ######################

    RSRC_PATH = 'patches'

    CONTAINER_CLASS = Windu::SoftwareTitle

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute patchId
      # @return [Integer] The id number of this patch
      patchId: {
        class: :Integer,
        identifier: :primary,
        do_not_send: true,
        readonly: true
      },

      # @!attribute softwareTitleId
      # @return [Integer] The id number of the title which uses this patch
      softwareTitleId: {
        class: :Integer,
        do_not_send: true,
        readonly: true
      },

      # @!attribute absoluteOrderId
      # @return [Integer] The zero-based position of this patch among
      #   all those used by the title. Should be identical to the Array index
      #   of this patch in the #patches attribute of the SoftwareTitle
      #   instance that uses this patch.
      #   NOTE: This can only be changed via methods called on the
      #   PatchManager that contains the patch.
      absoluteOrderId: {
        class: :Integer,
        readonly: true
      },

      # @!attribute enabled
      # @return [Boolean] Is this patch enabled?
      enabled: {
        class: :Boolean
      },

      # @!attribute version
      # @return [String] The version on the title installed by this patch
      version: {
        class: :String,
        required: true
      },

      # @!attribute releaseDate
      # @return [Time] When this patch was released
      releaseDate: {
        class: :Time,
        required: true,
        to_ruby: :to_time,
        to_api: :time_to_api
      },

      # @!attribute standalone
      # @return [Boolean] Can this patch be installed as an initial installation?
      #   If not, it must be applied to an already-installed version of this title.
      #   NOTE: This is for reporting only, it is not used in patch policies
      standalone: {
        class: :Boolean
      },

      # @!attribute minimumOperatingSystem
      # @return [String] The lowest version of the OS that can run this patch
      #   NOTE: This is for reporting only. If there is a minimumOperatingSystem
      #   You'll still need to specify it in the capabilities for this patch.
      minimumOperatingSystem: {
        class: :String,
        required: true
      },

      # @!attribute reboot
      # @return [Boolean] Does the patch require a reboot after installation?
      reboot: {
        class: :Boolean
      },

      # @!attribute killApps
      # @return [Array<Windu::KillApp>] The apps that must be quit before
      #   installing this patch
      killApps: {
        class: Windu::KillAppManager,
        do_not_send: true,
        readonly: true
      },

      # @!attribute components
      # @return [Array<Windu::Component>] The components of this patch.
      #   NOTE: there can be only one!
      component: {
        class: Windu::Component,
        do_not_send: true,
        readonly: true
      },

      # @!attribute capabilities
      # @return [Array<Windu::CapabilityManager>] The criteria which identify
      #   computers capable of running, and thus installing, this patch.
      capabilities: {
        class: Windu::CapabilityManager,
        do_not_send: true,
        readonly: true
      }

    }.freeze

    # Constructor
    ######################

    def initialize(**init_data)
      super
      @capabilities = Windu::CapabilityManager.new @capabilities, container: self
      @killApps = Windu::KillAppManager.new @killApps, container: self
    end

    # Public Instance Methods
    ##########################################

    # Enable this Patch
    def enable
      return if enabled?

      if capabilities.empty? || component.nil? || component.criteria.empty?
        raise Windu::MissingDataError,
              'Patches must have at least one capability, and a component with at least one criterion, before they can be enabled'
      end

      self.enabled = true

      # Update the currentVersion of our title to this version if this patch is the
      # newest enabled patch
      container.currentVersion = version if container.patches.all_enabled.first == self

      :enabled
    end

    # Disable this Patch
    def disable
      return unless enabled?

      self.enabled = false
      :disabled
    end

    # Allow array managers to change the absoluteOrderId.
    #
    # @todo Only allow this to be called from a PatchManager.
    #
    # @param new_index [Integer] The new, zero-based index for this
    #   criterion.
    #
    # @return [Integer] the id of the updated criterion
    #
    def absoluteOrderId=(new_index)
      new_value = validate_attr :absoluteOrderId, new_index
      return if new_value == @absoluteOrderId

      update_on_server :absoluteOrderId, new_value
      @absoluteOrderId = new_value
    end

    # Update the local absoluteOrderId without updating it on
    # the server.
    #
    # Why??
    #
    # Because changing the value on the server for one criterion
    # using #absoluteOrderId=  will automatically change it on the
    # server for all the others.
    #
    # After changing one on the server and updating that one in the
    # local array, the ArrayManager will use this, without
    # updating the server, to change the value for all others in the
    # array to match their array index.
    #
    # @todo Only allow this to be called from a PatchManager.
    #
    # @return [void]
    def local_absoluteOrderId=(new_index)
      @absoluteOrderId = new_index
    end

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response, container_id: nil)
      @patchId = post_response[:patchId]
      @absoluteOrderId = post_response[:absoluteOrderId]

      @softwareTitleId = container_id

      @patchId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(put_response)
      @absoluteOrderId = put_response[:absoluteOrderId]

      @patchId
    end

  end # class Patch

end # module Windu
