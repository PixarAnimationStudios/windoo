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
  class KillAppManager < Windu::BaseClasses::ArrayManager

    # Constants
    ##################################

    MEMBER_CLASS = Windu::KillApp

    # Public Instance Methods
    ####################################

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
        container: container,
        appName: appName,
        bundleId: bundleId
      )

      # call the method from our superclass to add it to the array
      add_member new_ka
      new_ka.primary_id
    end

    # Update the details of an existing killApp
    #
    # Values not set in the params are left unchanged
    #
    # @param id [Integer] The killAppId of the desired killApp in the array
    #
    # @param attribs [Hash] The attribute(s) to update. See #add_killApp
    #
    # @return [Integer] The id of the updated killApp
    #
    def update_killApp(id, **attribs)
      ka = update_member(id, **attribs)
      ka.killAppId
    end

    # Delete a killApp
    #
    # @param id [Integer] The killAppId of the desired killApp in the array
    #
    # @return [Integer] The id of the deleted killApp
    #
    def delete_killApp(id)
      delete_member(id)
      id
    end

  end # module KillAppManager

end # module Windu
