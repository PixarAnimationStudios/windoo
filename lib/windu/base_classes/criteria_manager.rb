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
    class CriteriaManager < Windu::BaseClasses::ArrayManager

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

      # Public Instance Methods
      ####################################

      # Add a criterion to the end of this array.
      #
      # @param name [String] The name of the criterion
      #   To ask the server for an Array of all possible criteria names,
      #   use
      #     Windu::BaseClasses::CriteriaManager.available_names
      #
      # @param operator [String] The operator to use for
      #   comparing the value given here with the value for
      #   a computer.
      #   To ask the server for an Array of all operators available for some
      #   criterion, use
      #     Windu::BaseClasses::CriteriaManager.operators_for criterion_name
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
      # @param absoluteOrderId [Integer] The zero-based position of this criterion
      #   among all the others in the array. By default, this criterion will be added
      #   at '-1', the end of the array
      #
      # @return [Integer] The id of the new criterion
      #
      def add_criterion(name:, operator:, value:, type: 'recon', and_or: :and, absoluteOrderId: nil)
        absoluteOrderId ||= @managed_array.size

        new_criterion = self.class::MEMBER_CLASS.create(
          container: container,
          and_or: and_or,
          name: name,
          operator: operator,
          value: value,
          type: type.to_s,
          absoluteOrderId: absoluteOrderId
        )

        # call the method from our superclass to add it to the array
        add_member new_criterion, index: absoluteOrderId
        update_local_absoluteOrderIds
        new_criterion.primary_id
      end

      # Create a new criterion from the provided attributes and use it
      # to replace the one with the given id.
      #
      # @param id [Integer] The primary ID of the criterion to update.
      #   So for an array of Windu::Requirement, you would provide a 'requirementId'
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
      # @return [Integer] The id of the new criterion
      #
      def replace_criterion(id, name:, operator:, value:, type: 'recon', and_or: :and)
        victim = delete_member(id)

        add_criterion(
          and_or: and_or,
          name: name,
          operator: operator,
          value: value,
          type: type.to_s,
          absoluteOrderId: victim.absoluteOrderId
        )
      # no need to run update_local_absoluteOrderIds, we haven't changed the order,
      # and it was called by add_criterion

      # Windu::ConnectionError should only come from the Add operation.
      # The delete should give a Windu::NoSuchItemError if the id doesn't
      # exist on the server.
      rescue Windu::ConnectionError
        # make sure the victim was really removed from the array
        @managed_array.delete_if { |c| c.primary_id == victim.primary_id }

        # then re-add the victim in the same position
        add_criterion(
          and_or: victim.and_or,
          name: victim.name,
          operator: victim.operator,
          value: victim.value,
          type: victim.type.to_s,
          absoluteOrderId: victim.absoluteOrderId
        )
        # and re-raise the error
        raise
      end

      # Change the position of an existing criterion in the array
      #
      # @param id [Integer] The primary ID of the criterion to update.
      #   So for an array of Windu::Requirement, you would provide a 'requirementId'
      #
      # @param absoluteOrderId [Integer] The zero-based position to which you want to
      #   move the criterion. So if you want to make it the third criterion
      #   in the list, use 2.
      #
      # @return [Integer] the new absoluteOrderId
      #
      def move_criterion(id, absoluteOrderId:)
        criterion = update_member id, absoluteOrderId: absoluteOrderId
        move_member criterion, index: criterion.absoluteOrderId
        update_local_absoluteOrderIds
        absoluteOrderId
      end

      # Delete a criterion by its id
      #
      # @param id [Integer] The primary ID of the criterion to delete.
      #   So for an array of Windu::Requirement, you would provide a 'requirementId'
      #
      # @return [Integer] The id of the deleted criterion
      #
      def delete_criterion(id)
        delid = delete_member(id).deleted_id
        update_local_absoluteOrderIds
        delid
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
        @managed_array.each_with_index do |criterion, index|
          criterion.local_absoluteOrderId = index
        end
      end

    end # class Criterion

  end # module BaseClasses

end # module Windu
