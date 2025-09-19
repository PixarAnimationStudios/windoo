# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

# frozen_string_literal: true

# main module
module Windoo

  module BaseClasses

    # The common code for dealing with a managed array of objects in
    # Software Titles.
    #
    # Array Managers manage an Array of instances of API objects, preventing
    # direct access to the Array, but providing methods for adding, removing,
    # updating, and moving array members, while appropriatly interacting with the
    # API and maintaining consistency between the local Array and the server.
    #
    # This base class provides management of the actual Array, and doesn't
    # intentionally communicate with the server at all. However, it
    # may cause server interaction when calling methods on the objects held
    # in the Array.
    #
    # Instances of subclasses of this class are held by API objects instead
    # of the raw Array.
    #
    # For example, SoftwareTitles have a #patches method, which is a list
    # of all the patches for the title. In the raw API data Hash, the :patches
    # key contains an array of hashes of patch data.
    #
    # However, the SoftwareTitle#patches method does not return an Array.
    # Intead it returns an instance of Windoo::PatchManager, a subclass of this class,
    # which provides ways to add, update, and delete patches from the title.
    #
    # CAUTION: Do not instantiate (with .create) or delete members of the Array
    # directly, use the `add_*` and `delete_` methods of the Array Manager, so
    # that the local array automatically stays in sync with the server.
    #
    # TODO: Prevent instantiation of those objects outside of approved methods.
    #
    # Subclasses MUST define the constant MEMBER_CLASS to indicate the class of
    # the items we are managing
    #
    class ArrayManager

      # Constants
      ##################################
      ##################################

      PP_OMITTED_INST_VARS = %i[@container].freeze

      # Attributes
      ##################################
      ##################################

      # @return [APICollection] the API object that contains this manager
      attr_reader :container

      # Constructor
      ##################################
      ##################################

      # @param data [Array<Hash>] A JSON array of hashes from the API
      #   containing data the to construct one of these manager objects.
      #
      # @param container [Object] the object that contains this managed
      #   array of criteria
      #
      def initialize(data, container:)
        @container = container
        @managed_array = []
        return unless data

        @managed_array = data.map do |member_data|
          self.class::MEMBER_CLASS.instantiate_from_container(container: container, **member_data)
        end
      end

      # Public Instance Methods
      ##################################
      ##################################

      # Only selected items are displayed with prettyprint
      # otherwise its too much data in irb.
      #
      # @return [Array] the desired instance_variables
      #
      ###########################
      def pretty_print_instance_variables
        instance_variables - PP_OMITTED_INST_VARS
      end

      # @return [Array<Windoo::BaseClasses::Criterion>] A dup'd and frozen copy of
      #  the array of criteria maintained by this class
      ###########################
      def to_a
        @managed_array.dup.freeze
      end

      # Some convenience wrappers for common array methods
      # For other array methods, use #to_a to get the
      # actual (readonly dup of) the array.
      #####

      # @return [Object]
      ###########################
      def [](idx)
        @managed_array[idx]
      end

      # @return [Object]
      ###########################
      def first
        @managed_array.first
      end

      # @return [Object]
      ###########################
      def last
        @managed_array.last
      end

      # @return [Boolean]
      ###########################
      def empty?
        @managed_array.empty?
      end

      # @return [Integer]
      ###########################
      def size
        @managed_array.size
      end
      alias count size
      alias length size

      # Iterators - they have to use the
      # frozen dup from to_a, since they
      # might try to modify items as they
      # iterate.
      ###########################

      # @return [Array]
      ###########################
      def each(&block)
        to_a.each(&block)
      end

      # @return [Object, nil]
      ###########################
      def find(if_none = nil, &block)
        to_a.find if_none, &block
      end

      # @return [Object, nil]
      ###########################
      def find_by_attr(attr_name, value)
        return if empty?
        return unless @managed_array.first.respond_to? attr_name

        @managed_array.find { |i| i.send(attr_name) == value }
      end

      # @return [Integer, nil]
      ###########################
      def index(obj = nil, &block)
        return to_a.index(obj) if obj

        to_a.index(&block)
      end

      # Private Instance Methods
      ##################################
      ##################################
      private

      # Add a member to the array at a given position.
      #
      # Subclasses must define a related method to create the new member
      # object, then call this method to add it to the array, then do any
      # other processing needed after, e.g. returning some attribute of
      # the object.
      #
      # NOTE: This method does not communicate with the server. You must add
      # the object to the server in whatever method calls this one, preferably
      # before calling this one, so that any server errors are raised before
      # we insert the object into the array.
      #
      # @param new_member [Object] the object to be added to the array
      #
      # @param index [Integer] The array index at which to add the object.
      #   Defaults to -1 (the end of the array)
      #
      # @return [Object] the object that was added
      #
      ###########################
      def add_member(new_member, index: -1)
        @managed_array.insert index, new_member
        new_member
      end

      # Update the details of an existing array member
      #
      # Subclasses should define a related method to do any kind of non-standard
      # processing if needed, then call this method, perhaps after modifying the
      # given attribs hash.
      #
      # This method will then call the matching setter method for each attrib
      # provided, if available, passing in the new value.
      #
      # Those setters may or may not update the server immediately.
      #
      # @param id [Integer] The primary ID of the object to update.
      #   For an array of Windoo::Requirement, you would provide a value that is a
      #   'requirementId', for an array of Windoo::Patch, the value would
      #    be a 'patchId'.
      #
      # @param attribs [Hash] Key=>value pairs for attributes to be updated
      #   and the new values to be applied.
      #   Each key will be transformed into a setter method and sent to the
      #   object with the value as input to the setter.
      #
      #   If any special handling of an attrib is needed, the calling
      #   method should deal with that and modify the attribs hash
      #   before passing them into this method via #super.
      #
      #   NOTE: Explicit nils are sent!
      #
      #
      # @return [Object] the object that was updated
      #
      ###########################
      def update_member(id, **attribs)
        member = member_by_id(id)

        attribs.each do |attr_name, new_val|
          setter = "#{attr_name}="
          member.send setter, new_val if member.respond_to? setter
        end

        member
      end

      # Move a member to a new location in the array. This
      # does not talk to the server
      #
      # @param member [Object] the member to move
      #
      # @param index [Integer] the new index for the member
      #
      # @return [void]
      ###########################
      def move_member(member, index:)
        curr_idx = @managed_array.index { |m| m == member }

        @managed_array.insert index, @managed_array.delete_at(curr_idx)
      end

      # Delete a member of the array.
      #
      # This method will call the object's #delete method, if it has one,
      # which may delete it from the server. It will then delete it from
      # the local array
      #
      # Subclasses should define a related method that calls this one, doing
      # any processing before or after
      #
      # @param id [Integer] The primary ID of the object to delete.
      #   For an array of Windoo::Requirement, you would provide a value that is a
      #   'requirementId', for an array of Windoo::Patch, the value would
      #    be a 'patchId'.
      #
      # @return [Object] The object that was removed from the array
      #
      ###########################
      def delete_member(id)
        member = member_by_id(id)

        # call its delete method, which may delete it from the server
        member.delete if member.respond_to? :delete

        # delete from the array
        @managed_array.delete member

        member
      end

      # Delete all members of the array
      #
      # Subclasses should override, or define a related method that calls this one,
      # doing any processing before or after
      #
      # @return [void]
      #
      ###########################
      def delete_all_members
        @managed_array.each { |member| member.delete if member.respond_to? :delete }
        @managed_array = []
      end

      # Return a member of the array by searching for its 'primary_id'
      #
      # @param id [Integer] The primary ID of the object to return.
      #   For an array of Windoo::Requirement, you would provide a value that is a
      #   'requirementId', for an array of Windoo::Patch, the value would
      #    be a 'patchId'.
      #
      # @return [Object] The object with the given id
      #
      ###########################
      def member_by_id(id)
        member = @managed_array.find { |m| m.send(primary_id_key) == id }
        return member if member

        raise Windoo::NoSuchItemError, "No matching #{self.class::MEMBER_CLASS} with #{primary_id_key} #{id} found"
      end

      # The primary
      ###########################
      def primary_id_key
        @primary_id_key ||= self.class::MEMBER_CLASS.primary_id_key
      end

      ###########################
      def container_primary_id_key
        @container_primary_id_key ||= @container.class.primary_id_key
      end

    end # class Criterion

  end # module BaseClasses

end # module Windoo
