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
        do_not_send: true
      },

      # @!attribute softwareTitleId
      # @return [Integer] The id number of the title which uses this patch
      softwareTitleId: {
        class: :Integer,
        do_not_send: true
      },

      # @!attribute absoluteOrderId
      # @return [Integer] The zero-based position of this patch among
      #   all those used by the title. Should be identical to the Array index
      #   of this patch in the #patches attribute of the SoftwareTitle
      #   instance that uses this patch
      absoluteOrderId: {
        class: :Integer,
        readonly: true,
        do_not_send: true
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
        class: Time,
        to_ruby: :parse,
        to_api: :iso8601
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
        class: Windu::KillApp,
        multi: true,
        do_not_send: true
      },

      # @!attribute components
      # @return [Array<Windu::Component>] The components of this patch.
      #   NOTE: there can be only one!
      components: {
        class: Windu::Component,
        multi: true,
        do_not_send: true
      },

      # @!attribute capabilities
      # @return [Array<Windu::CapabilityManager>] The criteria which identify
      #   computers capable of running, and thus installing, this patch.
      capabilities: {
        class: Windu::CapabilityManager,
        do_not_send: true
      }

    }.freeze

    # Constructor
    ######################

    def initialize(**init_data)
      super

      @killApps ||= []
      @components ||= []
      @capabilities ||= []

      @killApps.map! { |data| Windu::KillApp.instantiate_from_container container: self, **data }
      @components.map! { |data| Windu::Component.instantiate_from_container container: self, **data }
      @capabilities = Windu::CapabilityManager.new @capabilities, container: self, softwareTitle: container
    end

    # Public Instance Methods
    ##########################################

    # Add a killApp to this patch
    #
    # A killApp idetifies apps that cannot be running while this patch
    # is installed. If the user is voluntarily applying the patch, they
    # will be asked to quit the killApp. If the patch is being applied
    # automatically, it will be killed automatically.
    #
    # @param appName [String] The name of the application that
    #   cannot be running to install this patch. e.g. Safari.app
    #
    # @param bundleId [String] The bundle id of the application
    #   that cannot be running to install this patch,
    #   e.g. com.apple.Safari
    #
    # @return [Integer] The id of the new killApp
    #
    def add_killApp(appName:, bundleId:)
      new_ka = Windu::KillApp.create(
        appName: appName,
        bundleId: bundleId
      )

      new_id = new_ka.save container_id: @patchId

      @killApps << new_ka

      new_id
    end

    # Update the details of an existing killApp
    #
    # You must provide either the Array index of the desired killApp
    # from the array, or the killAppId of one of them.
    #
    # Values not set in the params are left unchanged
    #
    # @param index [Integer] The array index of the desired killApp in the array
    #   Must be provided if not providing id.
    #
    # @param id [Integer] The killAppId of the desired killApp in the array
    #   Must be provided if not providing an index
    #
    # @param appName [String] The new name of the application that
    #   cannot be running to install this patch. e.g. Safari.app
    #
    # @param bundleId [String] The new bundle id of the application
    #   that cannot be running to install this patch,
    #   e.g. com.apple.Safari
    #
    # @return [Integer] The id of the updated killApp
    #
    def update_killApp(index: nil, id: nil, bundleId: nil, appName: nil)
      ka = killApp_by_index_or_id(index: index, id: id)

      ka.bundleId = bundleId if bundleId
      ka.operator = appName if appName

      ka.save
    end

    # Delete a killApp by its index or its id
    #
    # @param index [Integer] The array index of the desired killApp in the array
    #   Must be provided if not providing id.
    #
    # @param id [Integer] The killAppId of the desired killApp in the array
    #   Must be provided if not providing an index
    #
    # @return [Integer] The id of the deleted killApp
    #
    def delete_killApp(index: nil, id: nil)
      return if @killApps.empty?

      ka = killApp_by_index_or_id(index: index, id: id)

      @killApps.delete_if { |k| k == ka }
      ka.delete
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

    def killApp_by_index_or_id(index: nil, id: nil)
      if index
        ka = @killApps[index]
      elsif id
        ka = @killApps.find { |k| k.killAppId == id }
      else
        raise ArgumentError, 'Either index: or id: must be provided to locate the desired killApp'
      end
      raise Windu::NoSuchItemError, 'No matching killApp found' unless ka

      ka
    end

  end # class Patch

end # module Windu
