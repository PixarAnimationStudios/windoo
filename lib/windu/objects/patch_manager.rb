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

  # An object that manages the array of Patches in a
  # SoftwareTitle.
  #
  # This object is returned by SoftwareTitle.patches
  #
  #
  class PatchManager < Windu::BaseClasses::ArrayManager

    # Constants
    ####################################

    MEMBER_CLASS = Windu::Patch

    # Public Instance Methods
    ####################################

    # Add a Patch to this SoftwareTitle. NOTE: patches cannot be
    # enabled when added, you must call 'enable' on them after creating
    # any necessary sub-objects.
    #
    # Patches must be ordered from newest to oldest, and are indexed zero-based,
    # like Ruby Arrays.
    #
    # By default, patches are added at the front, index 0,meaning the are the newest.
    #
    # To make the new patch appear later in the order, provide a zero-based
    # integer as 'absoluteOrderId' (0, the first in the order, is the default).
    # So to add this new patch as older than the first and second, use
    #    absoluteOrderId: 2
    # All others will be adjusted automatically.
    #
    #
    # @param version [String] The version of the title that is installed
    #   by this patch. Required.
    #
    # @param minimumOperatingSystem [String] The lowest OS version that
    #   this patch will run on. Required.
    #
    # @param releaseDate [Time, String] The date and time this patch
    #   became available. Will be stored as a UTC timestampe in ISO8601 format.
    #
    # @param reboot [Boolean] Does this patch require a reboot after installation?
    #
    # @param standalone [Boolean] Can this patch be installed as the initial
    #   install of this SoftwareTitle? If not, a previous version must already
    #   be installed before this one can be.
    #
    # @param absoluteOrderId [Integer] The zero-based position of this patch among
    #   all the others for this title. Ordered from newest to oldest. By default,
    #   this patch will be added at '0'  the newest, first in the Array.
    #
    # @return [Integer] The id of the new Patch
    #
    def add_patch(version:, minimumOperatingSystem:, releaseDate: nil, reboot: nil, standalone: nil, absoluteOrderId: 0)
      new_patch = Windu::Patch.create(
        container: container,
        version: version,
        minimumOperatingSystem: minimumOperatingSystem,
        releaseDate: releaseDate,
        reboot: reboot,
        standalone: standalone,
        absoluteOrderId: absoluteOrderId
      )

      # call the method from our superclass to add it to the array
      add_member new_patch, index: absoluteOrderId
      update_local_absoluteOrderIds
      new_patch.primary_id
    end

    # Update a Patch in this SoftwareTitle.
    # Do not use this to update absoluteOrderId, instead
    # use #move_patch
    #
    # @param patchId [Integer] the id of the Patch to be updated.
    #
    # @param attribs [Hash] The attribute(s) to update. See #add_patch
    #
    # @return [Integer] The id of the updated Patch
    #
    def update_patch(patchId, **attribs)
      patch = update_member(patchId, **attribs)

      if attribs[:absoluteOrderId]
        move_member patch, index: patch.absoluteOrderId
        update_local_absoluteOrderIds
      end

      patch.patchId
    end

    # Change the position of an existing patch in the array
    # This just calls update_patch, with absoluteOrderId as
    # the only attribute.
    #
    # @param patchId [Integer] The patchId of the patch to update.
    #
    # @param absoluteOrderId [Integer] The zero-based position to which you want to
    #   move the patch. So if you want to make it the third patch
    #   in the list, use 2.
    #
    # @return [Integer] the new absoluteOrderId
    #
    def move_patch(patchId, absoluteOrderId:)
      update_patch patchId, absoluteOrderId: absoluteOrderId
      absoluteOrderId
    end

    # Delete a Patch from this SoftwareTitle
    #
    # When deleting a Patch via this method, it is deleted
    # from the server immediately, there is no need to #save
    # the SoftwareTitle
    #
    # @param patchId [Integer] the id of the Patch to be updated.
    #
    #
    # @return [Integer] The id of the deleted Patch
    #
    def delete_patch(patchId)
      patch = delete_member(patchId)

      # titles without a patch are not valid
      # so must be disabled
      patch.softwareTitle.disable if empty?

      update_local_absoluteOrderIds

      patchId
    end

    # Private Instance Methods
    ####################################
    private

    # Update the local absoluteOrderId of Array members
    # to match their array index, without updating the server
    # cuz the server should have done it automatically
    #
    # @return [void]
    def update_local_absoluteOrderIds
      @managed_array.each_with_index do |patch, index|
        patch.local_absoluteOrderId = index
      end
    end

  end # class PatcheManager

end # module Windu
