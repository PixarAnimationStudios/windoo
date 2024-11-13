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

# main module
module Windoo

  module Mixins

    # This should be included into The TitleEditor and
    # Admin classes that represent API collections in their
    # respective servers.
    #
    # It defines core methods for dealing with such collections.
    module APICollection

      # when this module is included, also extend our Class Methods
      def self.included(includer)
        Windoo.verbose_include includer, self
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

        ####################
        def self.extended(extender)
          Windoo.verbose_extend extender, self
        end

        # Make a new instance on the server.
        #
        # The attributes marked as required must be supplied
        # in the keyword args. Others may be included, or
        # may be added later. To see the required args, use
        # the .required_attributes class method
        #
        # @param container [Object] All objects other than SoftwareTitles
        #   are contained within other objects, and created via methods
        #   within those container objects. They will pass 'self'
        #
        # @param init_data [Hasn] The attributes of the new item as keyword
        #   arguments. Some may be required.
        #
        # @return [Object] A new instance of the class, already saved
        #   to the server.
        #
        ####################
        def create(container: nil, cnx: Windoo.cnx, **init_data)
          container = Windoo::Validate.container_for_new_object(
            new_object_class: self,
            container: container
          )

          unless (required_attributes & init_data.keys) == required_attributes
            raise ArgumentError,
                  "Missing one or more required attributes for #{self}: #{required_attributes.join ', '}"
          end

          # validate all init values
          json_attributes.each do |attr_name, attr_def|
            init_val = init_data[attr_name]
            if attr_def[:required]
              Windoo::Validate.not_nil(
                init_val,
                msg: "Value for #{attr_name}: must be provided"
              )
            end

            init_data[attr_name] = Windoo::Validate.json_attr init_val, attr_def: attr_def, attr_name: attr_name
          end
          # add the container if applicable
          init_data[:from_container] = container if container

          # Let other steps in the process know we are being called from #create
          init_data[:creating] = true

          # Create our instance
          obj = new(**init_data)

          # create it on the server
          obj.create_on_server cnx: cnx

          # return it
          obj
        end

        # Instantiate from the API directly.
        # @return [Object]
        #
        ####################
        def fetch(primary_ident, cnx: Windoo.cnx)
          if primary_ident.is_a? Hash
            raise 'All API objects other than SoftwareTitle are fetched only by their id number'
          end

          init_data = cnx.get("#{self::RSRC_PATH}/#{primary_ident}")
          init_data[:cnx] = cnx
          init_data[:fetching] = true
          new(**init_data)
        end

        # This is used by container classes to instantiate the objects they contain
        # e.g. when when instantiating a Patch, it needs to instantiate
        # killApps, components, and capabilites. it will do so with this method
        #
        ####################
        def instantiate_from_container(container:, **init_data)
          container = Windoo::Validate.container_for_new_object(
            new_object_class: self,
            container: container
          )
          init_data[:from_container] = container
          init_data[:cnx] = container.cnx
          new(**init_data)
        end

        ####
        def delete(primary_ident, cnx: Windoo.cnx)
          if primary_ident.is_a? Hash
            raise ArgumentError, 'All API objects other than SoftwareTitle are deleted only by their id number'
          end

          cnx.delete("#{self::RSRC_PATH}/#{primary_ident}")
        end

      end # module ClassMethods

      # Constructor
      ######################
      def initialize(**init_data)
        fetching = init_data.delete :fetching
        @cnx = init_data.delete :cnx

        @container ||= init_data.delete :from_container

        # we save 'creating' in an inst. var so we know to create
        # rather than update later on when we #save
        @creating = true if init_data[:creating]

        unless fetching || @container || @creating
          raise Windoo::UnsupportedError, "#{self.class} can only be instantiated using .fetch or .create, not .new"
        end

        super
      end

      # Public Instance Methods
      ####################

      # @return [APICollection] The object that contains this object, or nil
      #   if nothing contains this object
      # def container
      #   return @container if defined? @container

      #   @container =
      #     if defined? self.class::CONTAINER_CLASS
      #       container_id_key = self.class::CONTAINER_CLASS.primary_id_key
      #       container_id = send container_id_key
      #       self.class::CONTAINER_CLASS.fetch container_id
      #     end
      # end

      # @return [nil, Integer] our primary identifier value, regardless of its
      #   attribute name. Before creation, this is nil. After deletion, this is -1
      #
      ####################
      def primary_id
        send self.class.primary_id_key
      end

      # @return [Boolean] Is this object the same as another, based on their
      #   primary_id
      ####################
      def ==(other)
        return false unless self.class == other.class

        primary_id == other.primary_id
      end

      # @return [Integer] our primary identifier value before we were deleted.
      #   Before deletion, this is nil
      #
      ####################
      def deleted_id
        @deleted_id
      end

      # @return [Integer] our primary identifier value before we were deleted.
      #   Before deletion, this is nil
      #
      ####################
      def deleted_id
        @deleted_id
      end

      # @return [Windoo::APICollection] If this object is contained within another,
      #   then here is the object that contains it
      ####################
      def container
        @container
      end

      # @return [Windoo::Connection] The server connection for this object
      ####################
      def cnx
        @cnx
      end

      # @return [Windoo::SoftwareTitle] The SoftwareTitle object that ultimately
      #   contains this object
      ####################
      def softwareTitle
        return self if is_a? Windoo::SoftwareTitle

        return container if container.is_a? Windoo::SoftwareTitle

        container.softwareTitle
      end

      # Delete this object
      #
      # @return [Integer] The id of the object that was deleted
      #
      #############
      def delete
        self.class.delete primary_id, cnx: cnx
        @deleted_id = primary_id
        instance_variable_set "@#{self.class.primary_id_key}", -1
        @deleted_id
      end

      # create a new object on the server from this instance
      #
      # @param container_id [Integer, nil] the id of the object that will
      #   contain the one we are creating. If nil, then we are creating
      #   a SoftwareTitle.
      #
      # @return [Integer] The id of the newly created object
      #
      ####################
      def create_on_server(cnx: Windoo.cnx)
        unless @creating
          raise Windoo::UnsupportedError,
                "Do not call 'create_on_server' directly - use the .create class method."
        end

        @cnx = cnx
        rsrc = creation_rsrc
        resp = cnx.post rsrc, to_json

        update_title_modify_time(resp)

        # the container method woull only return nil for
        # SoftwareTitle objects
        container_id = container&.primary_id

        new_id = handle_create_response(resp, container_id: container_id)

        # no longer creating, future saves are updates
        remove_instance_variable :@creating

        new_id
      end

      # Update a single attribute on the server with the current value.
      #
      # @param attr_name [Symbol] The key from Class.json_attributes for the value
      #   we want to update
      #
      # @param alt_value [Object] A value to send that isn't the actual data for the attribute.
      #   If provided, the attr_name need not appear as a key in .json_attributes, but
      #   that name and this value will be sent to the API. See CriteriaManager#update_criterion
      #   for an example
      #
      #
      # @return [Integer] the id of the updated item.
      ####################
      def update_on_server(attr_name, new_value)
        # This may be nil if given an alt name for an alt value
        attr_def = self.class.json_attributes[attr_name]

        if attr_def&.dig attr_name, :do_not_send
          raise Windoo::UnsupportedError, "The value for #{attr_name} cannot be updated directly."
        end

        # convert the value, if needed, to API format
        value_to_send =
          if attr_def&.dig attr_name, :to_api
            Windoo::Converters.send attr_def[:to_api], new_value.dup
          else
            new_value
          end

        json_to_put = { attr_name => value_to_send }.to_json

        # should use our @cnx...
        resp = cnx.put "#{self.class::RSRC_PATH}/#{primary_id}", json_to_put
        update_title_modify_time(resp)
        handle_update_response(resp)
      end

      # Remove the cnx  object from
      # the instance_variables used to create
      # pretty-print (pp) output.
      #
      # @return [Array] the desired instance_variables
      ####################
      def pretty_print_instance_variables
        vars = instance_variables.sort
        vars.delete :@cnx
        vars.delete :@container
        vars
      end

      # Private Instance Methods
      ####################
      private

      # update the timestamp on the title that contains this object
      ####################
      def update_title_modify_time(resp)
        if is_a? Windoo::SoftwareTitle
          @lastModified = Time.parse(resp[:lastModified])
        else
          softwareTitle.update_modification_time
        end
      end

      # figure out the resource path to use for POSTing this thing to the server
      #
      # @param container_id [Integer, nil] the id of the object that will
      #   contain the one we are creating. If nil, then we are creating
      #   a SoftwareTitle.
      #
      # @return [String] The resource path for POSTing to the server
      #
      ####################
      def creation_rsrc
        # if no container id was given, the only thing we can create is
        # a SoftwareTitle.  Everything else is created via its container.
        return Windoo::SoftwareTitle::RSRC_PATH unless @container

        "#{self.class::CONTAINER_CLASS::RSRC_PATH}/#{@container.primary_id}/#{self.class::RSRC_PATH}"
      end

    end # module APICollection

  end # module Mixins

end # module Windoo
