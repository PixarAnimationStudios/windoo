# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  # A {Windoo::BaseClasses::CriteriaManager CriteriaManager} for dealing with the
  # {Windoo::Requirement Requirements} of a {Windoo::SoftwareTitle SoftwareTitle}
  #
  # An instance of this is returned by {SoftwareTitle#requirements}
  #
  class RequirementManager < Windoo::BaseClasses::CriteriaManager

    # Constants
    ######################

    MEMBER_CLASS = Windoo::Requirement

    # Public Instance Methods
    #################################

    # Override this method to disable the containing patch
    # if there are no more capabilities.
    #
    def delete_criterion(id)
      deleted_id = super

      # Titles without a requirement are not valid
      # so must be disabled
      @container.disable if @managed_array.empty?

      deleted_id
    end

    # Delete all the criteria
    #
    # @return [void]
    #
    def delete_all_criteria
      delete_all_members
      # titles without a requirement are not valid
      # so must be disabled
      @container.disable
    end

  end # class RequirementManager

end # Module Windoo
