# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  # An {Windoo::BaseClasses::ArrayManager ArrayManager} for dealing with the
  # {Windoo::KillApp KillApps} of a {Windoo::Patch Patch}
  #
  # An instance of this is returned by {Patch#killApps}
  class KillAppManager < Windoo::BaseClasses::ArrayManager

    # Constants
    ##################################

    MEMBER_CLASS = Windoo::KillApp

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
      new_ka = Windoo::KillApp.create(
        cnx: container.cnx,
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
      delete_member(id).deleted_id
    end

    # Delete all the killApps
    #
    # @return [void]
    #
    def delete_all_killApps
      delete_all_members
    end

  end # module KillAppManager

end # module Windoo
