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
module Windoo

  module BaseClasses

    # The common code for dealing with a group of criteria-based objects
    # in Software Titles.
    #
    # This class manages an array of instances of subclasses of
    # {Windoo::BaseClasses::Criterion Windoo::BaseClasses::Criterion}
    #
    # See also: {Windoo::BaseClasses::ArrayManager Windoo::BaseClasses::ArrayManager}
    # for info about managed Arrays.
    #
    # This class should be the superclass of classes representing
    # the three ways Criteria are used in a {SoftwareTitle}.
    #
    # - SoftwareTitles have 'requirements'
    #   - These are criteria defining which computers have any version of the title installed.
    # - {Patch Patches} within SoftwareTitles have 'capabilities'
    #   - These are criteria defining which computers are capable of installing/running the patch.
    # - A Patch's '{Component component}' has a set of 'criteria'
    #   - These are criteria defining which comptuers have _this_ version of the title installed.
    #
    # Here's how that looks for requirements:
    #
    #   - {Windoo::RequirementManager Windoo::RequirementManager} should be a subclass of this class, and must define<br/>
    #     the constant `MEMBER_CLASS = Windoo::Requirement` indicating that it should manage an array of...
    #   - {Windoo::Requirement Windoo::Requirement} objects which is a subclass of {Windoo::BaseClasses::Criterion}
    #   - {Windoo::SoftwareTitle#requirements} should return a single {Windoo::RequirementManager Windoo::RequirementManager} object
    #
    # Here's how to use a {Windoo::RequirementManager Windoo::RequirementManager}:
    #
    #     title = Windoo::SoftwareTitle.fetch 'mytitle'
    #     title.requirements.to_a
    #     # => the readonly Array of Windoo::Requirement objects
    #
    #     title.requirements.add_criterion(options: here)
    #     # => add a new Windoo::Requirement to the Array
    #
    #     title.requirements.replace_criterion(victim_id, options: here)
    #     # => replace an existing Windoo::Requirement in the Array
    #
    #     title.requirements.delete_criterion(victim_id)
    #     # => delete an existing Windoo::Requirement from the Array
    #
    # The other CriteriaManagers work the same way, they are just located in their respective places:
    #
    #     # Patch Capabilities
    #
    #     patch = title.patches.first
    #     # => a single patch
    #
    #     patch.capabilities.to_a
    #     # => the readonly Array of Windoo::Capability objects
    #
    #     patch.capabilities.add_criterion(options: here)
    #     # => add a new Windoo::Capability to the patch
    #
    #     patch.capabilities.replace_criterion(victim_id, options: here)
    #     # => replace an existing Windoo::Capability in the patch
    #
    #     patch.capabilities.delete_criterion(victim_id)
    #     # => delete an existing Windoo::Capability from the patch
    #
    #     # Patch Component Criteria
    #
    #     component = patch.component
    #     # => the component of a patch
    #
    #     component.criteria.to_a
    #     # => the readonly Array of Windoo::ComponentCriterion objects
    #
    #     component.criteria.add_criterion(options: here)
    #     # => add a new Windoo::ComponentCriterion to the component
    #
    #     component.criteria.replace_criterion(victim_id, options: here)
    #     # => replace an existing Windoo::ComponentCriterion in the component
    #
    #     component.criteria.delete_criterion(victim_id)
    #     # => delete an existing Windoo::ComponentCriterion from the component
    #
    #
    # Subclasses MUST define the constant MEMBER_CLASS to indicate the class of the items we are managing
    #
    class CriteriaManager < Windoo::BaseClasses::ArrayManager

      # Class Methods
      ######################

      # @return [Array<String>] The names of all available recon criteria names
      #####
      def self.available_names(cnx: Windoo.cnx)
        cnx.get 'valuelists/criteria/names'
      end

      # @return [Array<String>] The possible criteria types
      #####
      def self.available_types(cnx: Windoo.cnx)
        cnx.get 'valuelists/criteria/types'
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
      def self.operators_for(name, cnx: Windoo.cnx)
        cnx.post 'valuelists/criteria/operators', { name: name }
      end

      # Public Instance Methods
      ####################################

      # Add a criterion to the end of this array.
      #
      # @param name [String] The name of the criterion
      #   To ask the server for an Array of all possible criteria names,
      #   use
      #     Windoo::BaseClasses::CriteriaManager.available_names
      #
      # @param operator [String] The operator to use for
      #   comparing the value given here with the value for
      #   a computer.
      #   To ask the server for an Array of all operators available for some
      #   criterion, use
      #     Windoo::BaseClasses::CriteriaManager.operators_for criterion_name
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
      #   So for an array of Windoo::Requirement, you would provide a 'requirementId'
      #
      # @param name [String] The name of the criterion
      #   To get an Array of all possible criteria names, use
      #   Windoo::BaseClasses::CriteriaManager.available_names
      #
      # @param operator [String] The operator to use for
      #   comparing the value given here with the value for
      #   a computer.
      #   To get an Array of all operators available for some criterion,
      #   use Windoo::BaseClasses::CriteriaManager.operators_for criterion_name
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

      # Windoo::ConnectionError should only come from the Add operation,
      # usually when one of the attributes given was a problem.
      #
      # The delete should give a Windoo::NoSuchItemError if the id doesn't
      # exist on the server.
      rescue Windoo::ConnectionError
        # make sure the victim was really removed from the array
        # It should have been by the delete_member call above,
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
      #   So for an array of Windoo::Requirement, you would provide a 'requirementId'
      #
      # @param absoluteOrderId [Integer] The zero-based position to which you want to
      #   move the criterion. So if you want to make it the third criterion
      #   in the list, use 2.
      #
      # @return [Integer] the new absoluteOrderId
      #
      def move_criterion(id, absoluteOrderId:)
        # Can't move it beyond the end of the array....
        max_idx = @managed_array.size - 1
        absoluteOrderId = max_idx if absoluteOrderId > max_idx

        # ... or before the beginning
        absoluteOrderId = 0 if absoluteOrderId.negative?

        # do it on the server first, to raise potential errs before
        # modifying the array
        criterion = update_member id, absoluteOrderId: absoluteOrderId

        # now modify the array
        move_member criterion, index: absoluteOrderId
        update_local_absoluteOrderIds

        absoluteOrderId
      end

      # Delete a criterion by its id
      #
      # @param id [Integer] The primary ID of the criterion to delete.
      #   So for an array of Windoo::Requirement, you would provide a 'requirementId'
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
          next unless criterion

          criterion.local_absoluteOrderId = index
        end
      end

    end # class Criterion

  end # module BaseClasses

end # module Windoo
