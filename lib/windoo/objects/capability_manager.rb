# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  # A {Windoo::BaseClasses::CriteriaManager CriteriaManager} for dealing with the
  # {Windoo::Capability Capabilities} of a {Windoo::Patch Patch}
  #
  # An instance of this is returned by {Patch#capabilities}
  #
  class CapabilityManager < Windoo::BaseClasses::CriteriaManager

    # Constants
    ######################

    MEMBER_CLASS = Windoo::Capability

    # Public Instance Methods
    #################################

    # Override this method to disable the containing patch
    # if there are no more capabilities.
    #
    def delete_criterion(id)
      deleted_id = super

      # patches without a capabliity are not valid
      # so must be disabled
      @container.disable if @managed_array.empty?

      deleted_id
    end

    # Delete all the criteria
    #
    # @return [void]
    #
    def delete_all_criteria
      super
      # patches without a capabliity are not valid
      # so must be disabled
      @container.disable
    end

  end # class RequirementManager

end # Module Windoo
