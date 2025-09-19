# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# main module
module Windoo

  module BaseClasses

    # The base class for dealing with criteria in Software Titles.
    #
    # WARNING: CRITERIA ARE IMMUTABLE. See below for how to deal
    # with this
    #
    # Criteria are individual comparisons or 'filter rules' used  to
    # identify matching computers, much as they are used for Jamf Smart
    # Groups or Advanced Searches.
    #
    # For example, a single criterion might specify all computers where
    # the app 'FooBar.app' is installed. Another might specify that
    # FooBar.app is version 12.3.6, or that the OS is Big Sur or higher.
    #
    # In SoftwareTitles, criteria are used in three places:
    #
    # - As the 'requirements' of a Software Title.
    #   Each requrement is one criterion, and the Array of them
    #   define which computers have any version of the title
    #   installed. Access to the Array is handled via the
    #   Windoo::RequirementManager class.
    #
    # - As the criteria of the sole 'component' of a Patch.
    #   A Patch's 'components' is an Array of one item (for historical
    #   reasons apparently).  That component contains an Array of
    #   criteria that define which computers have _that specific_
    #   version of the Patch's Title installed. Access to the Array is
    #    handled via the  Windoo::ComponentCriteriaManager class.
    #
    # - As the 'capabilities' of a Patch.
    #   Each capability is one criterion, and the Array of them
    #   define which computers are capable of running, and thus
    #   allowed to install, this Patch. Access to the Array is handled
    #   via the Windoo::CapabilitytManager class.
    #
    # This class is the superclass of the individual types of criteria
    # used in the Title Editor. For example Windoo::Requirement is a
    # subclass of this class.
    #
    # Criteria always come in groups (perhaps a group of one) and are
    # stored in Arrays. However, the arrays are not directly accessible,
    # but are managed by subclasses of Windoo::CriteriaManager. For
    # example, the Windoo::Requirement objects of a SoftwareTitle are stored
    # in an instance of Windoo::RequirementManager.
    #
    # These 'managers' provide methods for adding, replacing, moving,
    # and deleting the individual criteria in the array, and maintain
    # consistency between the local array and the actual objects stored
    # on the server.
    #
    # CRITERIA ARE IMMUTABLE:
    #
    # Criteria are immutable once created, mostly because to modify any of the
    # primary values of one (name, operator, & value), you have to modify them
    # all at once or you end up in a chicken/egg situation where the server will
    # complain of invalid values, which can't easily  be worked around when
    # updating the values individually.
    #
    # Instead of modifying one, delete it and replace it with a new one in the
    # same position in the array. There's a convenience method for this in the
    # CriteriaManager called #replace_criterion(id)
    #
    # When creating criteria using CriteriaManager#add_criterion, they area added
    # to the end of the array by default, but you can specify the position using the
    # absoluteOrderId value. You can also move the position of a criterion in the
    # array using CriteriaManager#update_criterion method and passing in the new
    # absoluteOrderId value.
    #
    class Criterion < Windoo::BaseClasses::JSONObject

      # Mixins
      #####################

      extend Windoo::Mixins::Immutable

      # Constants
      #####################

      # The authoritative list of available types can be read from the API
      # at GET 'valuelists/criteria/types', or also via
      # Windoo::BaseClasses::CriteriaManager.available_types

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
        return unless @and_or.nil?

        @and_or = @init_data[:and] == false ? :or : :and
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

      # Allow array managers to change the absoluteOrderId.
      #
      # @todo Only allow this to be called from a CriteriaManager.
      #
      # @param new_index [Integer] The new, zero-based index for this
      #   criterion.
      #
      # @return [Integer] the id of the updated criterion
      #
      def absoluteOrderId=(new_index)
        new_value = validate_attr :absoluteOrderId, new_index
        return if new_value == @absoluteOrderId

        update_on_server :absoluteOrderId, new_value
        @absoluteOrderId = new_value
      end

      # Update the local absoluteOrderId without updating it on
      # the server.
      #
      # Why??
      #
      # Because changing the value on the server for one criterion
      # using #absoluteOrderId=  will automatically change it on the
      # server for all the others.
      #
      # After changing one on the server and updating that one in the
      # local array, the CriteriaManager will use this, without
      # updating the server, to change the value for all others in the
      # array to match their array index.
      #
      # @todo Only allow this to be called from a CriteriaManager.
      #
      # @return [void]
      def local_absoluteOrderId=(new_index)
        @absoluteOrderId = new_index
      end

    end # class Criterion

  end # module BaseClasses

end # module Windoo
