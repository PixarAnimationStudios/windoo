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

# main module
module Windu

  module BaseClasses

    # The common code for dealing with a group of criteria-based objects
    # in Software Titles.
    #
    # This class manages an array of instances of subclasses of
    # Windu::BaseClasses::Criterion
    #
    # This class should be the superclass of classes representing
    # the three ways Criteria are used in a SoftwareTitle.
    #
    # Here's how that looks....
    #
    # - Windu::RequirementManager should be a subclass of this class, and must define
    #   the constant MEMBER_CLASS = Windu::Requirement
    #   indicating that it should manage an array of...
    #
    # - Windu::Requirement objects which is a subclass of Windu::BaseClasses::Criterion
    #
    # - Windu::SoftwareTitle#requirements should return a single Windu::Requirements object
    #   and you can then use it like this
    #      title = Windu::SoftwareTitle.fetch 'mytitle'
    #      title.requirements.all
    #      # => the readonly Array of Windu::Requirement objects
    #      title.requirements.add_criterion(options: here)
    #      # => add a new Windu::Requirement to the Array
    #      title.requirements.update_criterion(options: here)
    #      # => update an existing Windu::Requirement in the Array
    #      title.requirements.delete_criterion(options: here)
    #      # => delete an existing Windu::Requirement from the Array
    #
    #
    # - Windu::CapabilityManager should be a subclass of this class, and must define
    #   the constant MEMBER_CLASS = Windu::Capability
    #   indicating that it should manage an array of...
    #
    # - Windu::Capability objects which is a subclass of Windu::BaseClasses::Criterion
    #
    # - Windu::Patch#capabilities should return a single Windu::Capabilities object
    #   and you can then use it like this
    #      title = Windu::SoftwareTitle.fetch 'mytitle'
    #      a_patch = title.patches.first
    #      a_patch.capabilities.all
    #      # => the readonly Array of Windu::Capability objects
    #      a_patch.capabilities.add_criterion(options: here)
    #      # => add a new Windu::Capability to the patch
    #      a_patch.capabilities.update_criterion(options: here)
    #      # => update an existing Windu::Capability in the patch
    #      a_patch.capabilities.delete_criterion(options: here)
    #      # => delete an existing Windu::Capability from the patch
    #
    #
    # - Windu::ComponentCriteriaManager should be a subclass of this class, and must
    #   define the constant MEMBER_CLASS = Windu::ComponentCriterion
    #   indicating that it should manage an array of...
    #
    # - Windu::ComponentCriterion objects which is a subclass of Windu::BaseClasses::Criterion
    #
    # - Windu::Component#criteria should return a single Windu::ComponentCriteria object
    #   and you can then use it like this
    #      title = Windu::SoftwareTitle.fetch 'mytitle'
    #      a_patch = title.patches.first
    #      component = a_patch.component
    #      component.criteria
    #      # => a Windu::ComponentCriteria object
    #      component.criteria.all
    #      # => the readonly Array of Windu::ComponentCriterion objects
    #      component.criteria.add_criterion(options: here)
    #      # => add a new Windu::ComponentCriterion to the component
    #      component.capabilities.update_criterion(options: here)
    #      # => update an existing Windu::ComponentCriterion in the component
    #      component.capabilities.delete_criterion(options: here)
    #      # => delete an existing Windu::ComponentCriterion from the component
    #
    #
    # Subclasses MUST define the constant MEMBER_CLASS
    # to indicate the class of the items we are managing
    #
    class CriteriaManager

      # Constants
      #########################

      PP_OMITTED_INST_VARS = %i[@container @softwareTitle].freeze

      # Class Methods
      ######################

      # @return [Array<String>] The names of all available recon criteria names
      #####
      def self.available_names
        Windu.cnx.get 'valuelists/criteria/names'
      end

      # @return [Array<String>] The possible criteria types
      #####
      def self.available_types
        Windu.cnx.get 'valuelists/criteria/types'
      end

      # Find out the available critrion operators for a given criterion.
      # e.g. for the criterion 'Application Title' the operators are:
      #    ["is", "is not", "has", "does not have"]
      #
      # for the criterion 'Application Bundle ID' the operators are:
      #    ["is", "is not", "like", "not like", "matches regex", "does not match regex"]
      #
      # for the criterion 'Computer Group' the operators are:
      #    ["member of", "not member of"]
      #
      # ...and so on.
      #
      # @param name [String] The criterion for which to get the operators
      #
      # @return [Array<String>] The possible operators for a given criterion name
      #
      #####
      def self.operators_for(name)
        Windu.cnx.post 'valuelists/criteria/operators', { name: name }
      end

      # Constructor
      ####################################

      # @param data [Array<Hash>] An array of JSON data from the API
      #   containing the to construct one of these maintainer objects.
      #
      # @param container [Object] the object that contains this managed
      #   array of criteria
      #
      # @param softwareTitle [Windu::SoftwareTitle] The title that
      #   ultimately contains this array of criteria, for some subclasses
      #   this may be the same as the container.
      #
      def initialize(data, container:, softwareTitle:)
        @container = container
        @softwareTitle = softwareTitle
        @criteria_array = data.map do |criterion_data|
          self.class::MEMBER_CLASS.instantiate_from_container(container: container, **criterion_data)
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

      # @return [Array<Windu::BaseClasses::Criterion>] A dup'd and frozen copy of
      #  the array criteria maintained by this class
      def all
        @criteria_array.dup.freeze
      end

      # Add a criterion to the end of this array.
      #
      # When adding the criterion via this method, it is added
      # immediately to the server, there is no need to #save
      # the container object
      #
      # @param name [String] The name of the criterion
      #   To get an Array of all possible criteria names, use
      #   Windu::BaseClasses::CriteriaManager.available_names
      #
      # @param operator [String] The operator to use for
      #   comparing the value given here with the value for
      #   a computer.
      #   To get an Array of all operators available for some criterion,
      #   use Windu::BaseClasses::CriteriaManager.operators_for criterion_name
      #
      # @param value [String, integer] The value that will be
      #   compared with that on a computer, using the operator.
      #
      # @param type [String] how does Jamf Pro get this
      #   value for a computer? 'recon' means its a normal value
      #   gathered by a recon. 'extensionAttribute' means the value
      #   is generated by the extensionAttribute associated with
      #   this SoftwareTitle. Defaults to 'recon'.
      #
      # @param and_or [Symbol] :and or :or. Defines how this
      #   criterion is joined with the previous one in a chain of
      #   boolean logic. Default is :and
      #
      #
      # @return [Integer] The id of the new criterion
      #
      def add_criterion(name:, operator:, value:, type: 'recon', and_or: :and)
        new_criterion = self.class::MEMBER_CLASS.create(
          container: self,
          name: name,
          operator: operator,
          value: value,
          type: type.to_s,
          and_or: and_or
        )

        @softwareTitle.lastModified = Time.now.utc
        @criteria_array << new_criterion

        new_new_criterion.primary_id
      end

      # Update the details of an existing criterion
      #
      # You must provide either the Array index of the desired criterion
      # from the array, or the primary ID of one of them.
      #
      # For the other params, @see #add_criterion. If left nil, they are
      # not changed.
      #
      # @param index [Integer] The array index of the criterion in the array
      #   Must be provided if not providing id.
      #
      # @param id [Integer] The primary ID of the criterion in the array
      #   So for an array of Windu::Requirement, you would provide a 'requirementId'
      #   Must be provided if not providing index.
      #
      # @return [Integer] The id of the updated criterion
      #
      def update_criterion(index: nil, id: nil, name: nil, operator: nil, value: nil, type: nil, and_or: nil)
        criterion = criterion_by_index_or_id(index: index, id: id)

        criterion.name = name if name
        criterion.operator = operator if operator
        criterion.value = value if value
        criterion.type = type.to_s if type
        criterion.and_or = and_or if and_or

        @softwareTitle.lastModified = Time.now.utc
        id
      end

      # Delete a criterion by its index or its id
      #
      # @param index [Integer] The array index of the criterion in the array
      #   Must be provided if not providing id.
      #
      # @param id [Integer] The primary ID of the criterion in the array
      #   So for an array of Windu::Requirement, you would provide a 'requirementId'
      #   Must be provided if not providing index.
      #
      # @return [Integer] The id of the deleted criterion
      #
      def delete_criterion(index: nil, id: nil)
        return if @criteria_array.empty?

        criterion = criterion_by_index_or_id(index: index, id: id)
        @criteria_array.delete_if { |c| c == criterion }
        del_id = criterion.delete
        @softwareTitle.lastModified = Time.now.utc
        del_id
      end

      # Private Instance Methods
      ##################################
      private

      def criterion_by_index_or_id(index: nil, id: nil)
        if index
          criterion = @criteria_array[index]
        elsif id
          criterion = @criteria_array.find { |c| c.send(primary_id_key) == id }
        else
          raise ArgumentError, 'Either index: or id: must be provided to locate the desired criterion'
        end
        raise Windu::NoSuchItemError, 'No matching criterion found' unless criterion

        criterion
      end

      def primary_id_key
        @primary_id_key ||= self.class::MEMBER_CLASS.primary_id_key
      end

      def container_primary_id_key
        @container_primary_id_key ||= @container.class.primary_id_key
      end

    end # class Criterion

  end # module BaseClasses

end # module Windu
