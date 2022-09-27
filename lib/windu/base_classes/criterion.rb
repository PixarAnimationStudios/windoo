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
#

# main module
module Windu

  module BaseClasses

    # The base class for dealing with criteria in Software Titles.
    #
    # Criteria are individual comparisons or 'filter rules' used singly or
    # in ordered groups (stored in an Array) to identify matching computers,
    # much as they are used for Jamf Smart Groups or Advanced Searches.
    #
    # For example, a single criterion might specify all computers where
    # the app 'FooBar.app' is installed. Another might specify that
    # FooBar.app is version 12.3.6, or that the OS is Big Sur or higher.
    #
    # The arrays are not directly accessible, but are managed by subclasses
    # of Windu::CriteriaManager.
    #
    # In SoftwareTitles, criteria are used in three places:
    #
    # - As the 'requirements' of a Software Title.
    #   Each requrement is one criterion, and the Array of them
    #   define which computers have any version of the title
    #   installed. Access to the Array is handled via the
    #   Windu::RequirementManager class.
    #
    # - As the criteria of the sole 'component' of a Patch.
    #   A Patch's 'components' is an Array of one item (for historical
    #   reasons apparently).  That component contains an Array of
    #   criteria that define which computers have _that specific_
    #   version of the Patch's Title installed. Access to the Array is
    #    handled via the  Windu::ComponentCriteriaManager class.
    #
    # - As the 'capabilities' of a Patch.
    #   Each capability is one criterion, and the Array of them
    #   define which computers are capable of running, and thus
    #   allowed to install, this Patch. Access to the Array is handled
    #   via the Windu::CapabilitytManager class.
    #
    # Criteria are immutable once created, mostly because to modify any of the
    # primary values of one (name, operator, & value), you have to modify them all
    # at once or the server will complain of possible mismatches, which can't be
    # worked around when updating the values individually.
    #
    # Instead of modifying one, delete it and replace it with a new one in the
    # position in the array. There's a convenience method for this in the
    # CriteriaManager subclass called #replace_criterion(id)
    #
    # When creating criteria using CriteriaManager#add_criterion, they area added
    # to the end of the array by default, but you can specify the position using the
    # absoluteOrderId value. You can also move the position of a criterion in the
    # array using CriteriaManager#update_criterion method and passing in the new
    # absoluteOrderId value.
    #
    class Criterion < Windu::BaseClasses::JSONObject

      # Mixins
      #####################

      extend Windu::Mixins::Immutable

      # Constants
      #####################

      # The authoritative list of available types can be read from the API
      # at GET 'valuelists/criteria/types', or also via
      # Windu::BaseClasses::CriteriaManager.available_types

      TYPE_RECON = 'recon'
      TYPE_EA = 'extensionAttribute'

      TYPES = [TYPE_RECON, TYPE_EA].freeze

      # These attributes must be updated together for Criteria objects
      ATTRIBUTES_TO_UPDATE_TOGETHER = %i[name operator value].freeze

      # Attributes
      ######################

      JSON_ATTRIBUTES = {

        # @!attribute absoluteOrderId
        # @return [Integer] The zero-based position of this requirement among
        #   all those used by the title. Should be identical to the Array index
        #   of this requirement in the #requirements attribute of the SoftwareTitle
        #   instance that uses this requirement
        absoluteOrderId: {
          class: :Integer
        },

        # @!attribute and_or
        # @return [Symbol] Either :and or :or. This indicates how this criterion is
        #   joined to the previous one in a chain of boolean logic.
        #
        #   NOTE: In the Title Editor JSON data, this key for this value is the
        #   word "and" and its value is a boolean: if false, the joiner is "or".
        #   However, because "and" is a reserved word in ruby, we convert that
        #   value into this one during initialization, and back when sending
        #   data to the Title Editor.
        and_or: {
          class: :Symbol
        },

        # @!attribute name
        # @return [String] The name of the criteria to search in this requirement.
        #    See the API resource GET 'valuelists/criteria/names'
        name: {
          class: :String,
          required: true
        },

        # @!attribute operator
        # @return [String] The criteria operator to apply to the criteria name
        #    See the API resource POST 'valuelists/criteria/names',  {name: 'Criteria Name'}
        operator: {
          class: :String,
          required: true
        },

        # @!attribute value
        # @return [Object] The the value to apply with the operator to the named criteria
        #   We can't specify the class of the value, because it might be a String, Integer, Time, or
        #   something else.
        value: {
          class: :Object
        },

        # @!attribute type
        # @return [String] What type of criteria is the named one?
        #   Must be one of the values in TYPES
        type: {
          class: :String,
          required: true
        }
      }.freeze

      # Constructor
      ######################
      def initialize(**init_data)
        super
        # if #super didn't set @and_or, set it now
        if @and_or.nil?
          @and_or = @init_data[:and] == false ? :or : :and
        end
      end

      # Public Instance Methods
      ################################

      # Override handle @and_or before creating
      #
      def to_api
        api_data = super
        api_data[:and] = (@and_or == :and)
        api_data.delete :and_or
        api_data
      end

      # allow array managers to change the absoluteOrderId
      # on the server
      def absoluteOrderId=(_new_order)
        new_value = validate_attr :absoluteOrderId, new_value
        old_value = @absoluteOrderId
        return if new_value == old_value

        @absoluteOrderId = new_value
        update_on_server :absoluteOrderId
      end

    end # class Criterion

  end # module BaseClasses

end # module Windu
