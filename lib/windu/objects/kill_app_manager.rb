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

  # Methods to mix in to the Patch class,
  # relating to KillApps
  #
  class KillAppManager

    # Constants
    #########################

    PP_OMITTED_INST_VARS = %i[@container @softwareTitle].freeze

    # Constructor
    ####################################

    # @param data [Array<Hash>] A JSON array of hashes from the API
    #   containing data the to construct one of these manager objects.
    #
    # @param container [Windu::Patch] The Patch that
    #   contains this array of KillApps
    #
    def initialize(data, container:)
      @patch = container
      @killApp_array = []
      return unless data

      @killApp_array = data.map do |ka_data|
        Windu::KillApp.instantiate_from_container(container: @patch, **ka_data)
      end
    end

    # Public Instance Methods
    ####################################

    # Only selected items are displayed with prettyprint
    # otherwise its too much data in irb.
    #
    # @return [Array] the desired instance_variables
    #
    def pretty_print_instance_variables
      instance_variables - PP_OMITTED_INST_VARS
    end

    # @return [Array<Windu::Patch>] A dup'd and frozen copy of
    #  the array Patches maintained by this class
    def to_a
      @killApp_array.dup.freeze
    end

    # @return [Boolean] is our array empty?
    def empty?
      @killApp_array.empty?
    end

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

      @killApp_array << new_ka
      new_ka.killAppId
    end

    # Update the details of an existing killApp
    #
    # Values not set in the params are left unchanged
    #
    # @param id [Integer] The killAppId of the desired killApp in the array
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
    def update_killApp(id, bundleId: nil, appName: nil)
      ka = killApp_by_id(id)

      ka.bundleId = bundleId if bundleId
      ka.operator = appName if appName

      ka.killAppId
    end

    # Delete a killApp
    #
    # @param id [Integer] The killAppId of the desired killApp in the array
    #
    # @return [Integer] The id of the deleted killApp
    #
    def delete_killApp(id)
      ka = killApp_by_id(id)

      # delete from the array
      @killApp_array.delete ka

      # delete from the server
      ka.delete
    end

    # Private Instance Methods
    ##########################################
    private

    def killApp_by_id(killAppId)
      killApp = @killApp_array.find { |p| p.patchId == killAppId }
      return killApp if killApp

      raise Windu::NoSuchItemError, "No killApp with killAppId #{killApp} in this Patch"
    end

  end # module KillAppManager

end # module Windu
