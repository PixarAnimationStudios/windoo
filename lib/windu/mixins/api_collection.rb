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

# frozen_string_literal: true

# main module
module Windu

  module Mixins

    # This should be included into The TitleEditor and
    # Admin classes that represent API collections in their
    # respective servers.
    #
    # It defines core methods for dealing with such collections.
    module APICollection

      # when this module is included, also extend our Class Methods
      def self.included(includer)
        Windu.verbose_include includer, self
        includer.extend(ClassMethods)
      end

      # REQUIRED ITEMS WHEN MIXING IN
      ###################################
      ###################################
      # Classes mixing in this module must define these things:

      # Constant RSRC_PATH
      ######
      # The path from which to GET, PUT, or DELETE
      # lists or instances of this class. e.g 'patches'
      # or 'softwaretitles'

      # Constant CONTAINER_CLASS
      ######
      # Except for softwaretitles, the POST/create path for
      # all objects is under the path of their container object.
      #
      # e.g. to create a patch for a softwaretitle, the path is:
      #     .../softwaretitles/{id}/patches
      #
      # and to create a killapp in a patch, it is:
      #     .../patches/{id}/killapps
      #
      # This constant allows this class to calculate
      # the POST path from its container's path, and gives
      # access to other data from the container class.

      # instance method #handle_create_response(post_response, container_id: nil)
      ######
      #
      # This method is called after a new object is created on the server,
      # and the data from the POST response is passed in.
      # This method should update the attributes with any new
      # data from the result, such as modification dates, ids, etc.
      #
      # It must return the primary identifier of the new object

      # instance method #handle_update_response(put_response)
      ######
      #
      # This method is called after an object is updated on the server,
      # and the data from the PUT response is passed in.
      # This method should update the attributes with any new
      # data from the result, such as modification dates, etc.
      #
      # It must return the primary identifier of the updated object

      ###################################
      ###################################

      # Class Methods
      #####################################
      module ClassMethods

        def self.extended(extender)
          Windu.verbose_extend extender, self
        end

        # Make a new instance to be created on the server.
        #
        # The attributes marked as required must be supplied
        # in the keyword args. Others may be included, or
        # may be added later. To see the required args, use
        # the .required_attributes class method
        #
        # @param args [Hasn] The attributes of the new item as keyword
        #   arguments. Some may be required.
        #
        # @return [Object] A new instance of the class, not yet saved
        #   to the server. To save it use the #save instance method.
        ####
        def create(**init_data)
          unless (required_attributes & init_data.keys) == required_attributes
            msg = "Missing one or more required attributes for #{self}: #{required_attributes.join ', '}"
            raise ArgumentError, msg
          end
          init_data[:creating] = true
          new init_data
        end

        # This is used by container classes to instantiate the objects they contain
        # e.g. when when instantiating a Patch, it needs to instantiate
        # killApps, components, and capabilites. it will do so with this method
        ####
        def instantiate_from_container(init_data)
          init_data[:from_container] = true
          new init_data
        end

        # @return [Object]
        ####
        def fetch(primary_ident)
          if primary_ident.is_a? Hash
            raise 'All API objects other than SoftwareTitle are fetched only by their id number'
          end

          init_data = Windu.cnx.get("#{self::RSRC_PATH}/#{primary_ident}")
          init_data[:fetching] = true
          new(**args)
        end

        ####
        def delete(primary_ident)
          if primary_ident.is_a? Hash
            raise 'All API objects other than SoftwareTitle are deleted only by their id number'
          end

          Windu.cnx.delete("#{self::RSRC_PATH}/#{primary_ident}")
        end

      end # module ClassMethods

      # Constructor
      ######################
      def initialize(init_data)
        fetching = init_data.delete :fetching
        from_container = init_data.delete :from_container

        # we save 'creating' in an inst. var so we know to create
        # rather than update later on when we #save
        @creating = init_data.delete :creating

        unless fetching || from_container || @creating
          raise Windu::UnsupportedError, "#{self.class} can only be instantiated using .fetch or .create, not .new"
        end

        super
      end

      # Public Instance Methods
      ####################

      # @return [nil, Integer] our primary identifier value, regardless of its
      #   attribute name. Before creation, this is nil. After deletion, this is -1
      #
      def primary_id
        send self.class.primary_ident_key
      end

      # @return [Integer] our primary identifier value before we were deleted.
      #   Before deletion, this is nil
      #
      def deleted_id
        @deleted_id
      end

      # Create or update
      #
      # When creating anything other than a SoftwareTitle, the id of the
      # container object must be supplied.
      #
      # @param container_id [Integer, nil] The id of the object that will
      #   contain the item being saved, if we are creating it anew.
      #   Ignored if updating an object already on the server.
      #
      # @return [Integer] the id of the saved object.
      #
      ####
      def save(container_id: nil)
        @creating ? create_on_server(container_id: container_id) : update_on_server
      end

      # Delete this object
      #
      # @return [Integer] The id of the object that was deleted
      #
      #############
      def delete
        self.class.delete primary_id
        @deleted_id = primary_id
        send "#{self.class.primary_ident_key}=", -1
        @deleted_id
      end

      # Private Instance Methods
      ####################
      private

      # create a new object on the server from this instance
      #
      # @param container_id [Integer, nil] the id of the object that will
      #   contain the one we are creating. If nil, then we are creating
      #   a SoftwareTitle.
      #
      # @return [Integer] The id of the newly created object
      #
      def create_on_server(container_id: nil)
        return unless @creating

        rsrc = creation_rsrc(container_id: container_id)
        resp = Windu.cnx.post rsrc, to_json

        new_id = handle_create_response(resp, container_id: container_id)

        # no longer creating, future saves are updates
        @creating = nil

        new_id
      end

      # figure out the resource path to use for POSTing this thing to the server
      #
      # @param container_id [Integer, nil] the id of the object that will
      #   contain the one we are creating. If nil, then we are creating
      #   a SoftwareTitle.
      #
      # @return [String] The resource path for POSTing to the server
      #
      def creation_rsrc(container_id: nil)
        # if no container id was given, the only thing we can create is
        # a SoftwareTitle.  Everything else is created via its container.
        return Windu::SoftwareTitle::RSRC_PATH unless container_id

        "#{self.class::CONTAINER_CLASS::RSRC_PATH}/#{container_id}/#{self.class::RSRC_PATH}"
      end

      def update_on_server
        resp = Windu.cnx.put "#{self.class::RSRC_PATH}/#{primary_id}", to_json
        handle_update_response(resp)
      end

    end # module APICollection

  end # module Mixins

end # module Windu
