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

  end # class RequirementManager

end # Module Windoo
