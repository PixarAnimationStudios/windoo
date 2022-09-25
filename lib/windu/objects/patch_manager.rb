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
  class PatchManager

    # Constants
    #########################

    PP_OMITTED_INST_VARS = %i[@container].freeze

    # Constructor
    ####################################

    # @param data [Array<Hash>] A JSON array of hashes from the API
    #   containing data the to construct one of these manager objects.
    #
    # @param container [Windu::SoftwareTitle] The title that
    #   contains this array of Patches
    #
    def initialize(data, container:)
      @softwareTitle = container
      @patch_array = []
      return unless data

      @patch_array = data.map do |patch_data|
        Windu::Patch.instantiate_from_container(container: @softwareTitle, **patch_data)
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
      @patch_array.dup.freeze
    end

    # @return [Boolean] is our array empty?
    def empty?
      @patch_array.empty?
    end

    # Add a Patch to this SoftwareTitle. NOTE: patches cannot be
    # enabled when added, you must call 'enable' on them after creating
    # any necessary sub-objects.
    #
    # @param version [String] The version of the title that is installed
    #   by this patch. Required.
    #
    # @param minimumOperatingSystem [String] The lowest OS version that
    #   this patch will run on. Required.
    #
    # @param releaseDate [Time, String] The date and time this patch
    #   became available.
    #
    # @param reboot [Boolean] Does this patch require a reboot after installation?
    #
    # @param standalone [Boolean] Can this patch be installed as the initial
    #   install of this SoftwareTitle? If not, a previous version must already
    #   be installed before this one can be.
    #
    # @return [Integer] The id of the new Patch
    #
    def add_patch(version:, minimumOperatingSystem:, releaseDate: nil, reboot: nil, standalone: nil)
      new_patch = Windu::Patch.create(
        container: self,
        version: version,
        minimumOperatingSystem: minimumOperatingSystem,
        releaseDate: releaseDate,
        reboot: reboot,
        standalone: standalone
      )

      @patch_array.unshift new_patch
      new_patch.patchId
    end

    # Update a Patch in this SoftwareTitle.
    #
    # @param patchId [Integer] the id of the Patch to be updated.
    #
    # @param version [String] The version of the title that is installed
    #   by this patch. Required.
    #
    # @param minimumOperatingSystem [String] The lowest OS version that
    #   this patch will run on. Required.
    #
    # @param releaseDate [Time, String] The date and time this patch
    #   became available.
    #
    # @param reboot [Boolean] Does this patch require a reboot after installation?
    #
    # @param standalone [Boolean] Can this patch be installed as the initial
    #   install of this SoftwareTitle? If not, a previous version must already
    #   be installed before this one can be.
    #
    # @return [Integer] The id of the updated Patch
    #
    def update_patch(patchId, version: nil, minimumOperatingSystem: nil, releaseDate: nil, reboot: nil, standalone: nil)
      patch = patch_by_id(patchId)

      patch.version = version if version
      patch.minimumOperatingSystem = minimumOperatingSystem if minimumOperatingSystem
      patch.releaseDate = releaseDate if releaseDate
      patch.reboot = reboot if reboot
      patch.standalone = standalone if standalone

      patch.patchId
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
      patch = patch_by_id(patchId)

      # delete from the array
      @patch_array.delete patch

      # delete from the server
      patch.delete

      # titles without a patch are not valid
      # so must be disabled
      patch.softwareTitle.disable if @patch_array.empty?

      patchId
    end

    # Private Instance Methods
    ################################
    private

    def patch_by_id(patchId)
      patch = @patch_array.find { |p| p.patchId == patchId }
      return patch if patch

      raise Windu::NoSuchItemError, "No patch with patchId #{patchId} in this SoftwareTitle"
    end

  end # class PatcheManager

end # module Windu
