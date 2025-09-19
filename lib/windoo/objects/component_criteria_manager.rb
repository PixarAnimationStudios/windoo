# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  # A {Windoo::BaseClasses::CriteriaManager CriteriaManager} for dealing with the
  # {Windoo::CompnentCriterion CompnentCriteria} of a {Windoo::Component Component}
  # of a {Windoo::Patch Patch}
  #
  # An instance of this is returned by {Component#criteria}
  #
  class ComponentCriteriaManager < Windoo::BaseClasses::CriteriaManager

    # Constants
    ######################

    MEMBER_CLASS = Windoo::ComponentCriterion

  end # class RequirementManager

end # Module Windoo
