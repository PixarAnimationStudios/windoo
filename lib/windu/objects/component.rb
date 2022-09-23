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

  # A component holds a bunch of criteria defining which computers
  # have a specific patch version installed.
  class Component < Windu::BaseClasses::JSONObject

    # Mixins
    ######################

    include Windu::Mixins::APICollection

    # Constants
    ######################

    RSRC_PATH = 'components'

    CONTAINER_CLASS = Windu::Patch

    # Attributes
    ######################

    JSON_ATTRIBUTES = {

      # @!attribute componentId
      # @return [Integer] The id number of this component
      componentId: {
        class: :Integer,
        identifier: :primary,
        do_not_send: true
      },

      # @!attribute patchId
      # @return [Integer] The id number of the patch which uses this component
      patchId: {
        class: :Integer,
        do_not_send: true
      },

      # @!attribute name
      # @return [String] The name of the Software Title for this patch
      name: {
        class: :String
      },

      # @!attribute version
      # @return [String] The version installed by this patch
      version: {
        class: :String
      },

      # @!attribute criteria
      # @return [Array<Windu::ComponentCriterion>] The criteria used by
      # this component.
      criteria: {
        class: Windu::ComponentCriteriaManager,
        do_not_send: true
      }

    }.freeze

    # Constructor
    ######################

    def initialize(**init_data)
      super
      @criteria ||= []

      my_patch = container
      my_title = my_patch.container
      @criteria = Windu::ComponentCriteriaManager.new @criteria, container: self, softwareTitle: my_title
    end

  end # class Component

end # Module Windu
