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

  # A Software Title in the Title Editor
  #
  # NOTE: SoftwareTitles cannot be enabled when created.
  # You must call 'enable' on them after creating any
  # necessary sub-objects.
  #
  class SoftwareTitle < Windoo::BaseClasses::JSONObject

    # Mixins
    ######################

    include Windoo::Mixins::APICollection
    include Windoo::Mixins::SoftwareTitle::ExtensionAttribute

    # Constants
    ######################

    LOCAL_TITLE_EDITOR_SOURCE_NAME = 'Local'
    LOCAL_TITLE_EDITOR_SOURCE_ID = 0

    RSRC_PATH = 'softwaretitles'

    CONTAINER_CLASS = nil

    # Public Class Methods
    ######################

    # Software Titles are the only collection resource that
    # has an endpoint that returns summary list.
    #
    # All others, patches, components, ext attrs, etc...
    # can only be individually accessed using their
    # primary identifier, so the .all and .valid_id methods
    # are not applicable to them.
    #
    # .all returns summmary Hashes for all Software Titles
    # in the Title Editor
    # the Hash keys are:
    #
    # :softwareTitleId=>1,
    # :enabled=>false,
    # :name=>"Test",
    # :publisher=>"Some Company",
    # :appName=>nil,
    # :bundleId=>nil,
    # :lastModified=>"2022-09-10T22:06:39Z",
    # :currentVersion=>"5.0.1",
    # :requirements=>3,
    # :patches=>0,  # Number of enabled patches, not existing patches?
    # :id=>"com.somecompany.test",
    # :sourceId=>0,
    # :source=>"Local"
    #
    # @return [Array<Hash>]
    ####
    def self.all(cnx: Windoo.cnx)
      cnx.get(self::RSRC_PATH)
    end

    # @return [Array<String>] The ids (unique names) of all titles
    #####
    def self.all_ids(cnx: Windoo.cnx)
      all(cnx: cnx).map { |t| t[:id] }
    end

    # @return [Array<Integer>] The all_softwareTitleIds (numeric id numbers) of all titles
    #####
    def self.all_softwareTitleIds(cnx: Windoo.cnx)
      all(cnx: cnx).map { |t| t[:softwareTitleId] }
    end

    # Override the method from APICollection, because
    # SoftwareTitles can be looked up by both the primary_ident
    # (softwareTitleId) and secondary (id)
    #
    # @return [Windoo::SoftwareTitle]
    ####
    def self.fetch(ident = nil, cnx: Windoo.cnx, **key_and_ident)
      unless ident || !key_and_ident.empty?
        raise ArgumentError,
              "ident, or 'key: ident' is required to fetch #{self.class}"
      end

      id =
        if ident
          valid_id ident, raise_if_not_found: true, cnx: cnx
        else
          key, ident = key_and_ident.first

          # Dont call valid_id if we are fetching based on the primary_id_key
          # just used the value provided. The API will complain if it
          # doesn't exist
          key == primary_id_key ? ident : valid_id(ident, key: key, raise_if_not_found: true, cnx: cnx)
        end

      init_data = cnx.get("#{self::RSRC_PATH}/#{id}")
      init_data[:cnx] = cnx
      init_data[:fetching] = true

      new(**init_data)
    end

    # @param ident [Integer, String] the identifier value to search for
    #
    # @param key [Symbol] if given, Only look for the value in this key.
    #
    # @return [Integer, nil] given any identifier, return the matching primary id
    #   or nil if no match
    ####
    def self.valid_id(ident, key: nil, raise_if_not_found: false, cnx: Windoo.cnx)
      matched_summary =
        if key
          all(cnx: cnx).select { |summary| summary[key] == ident }.first
        else
          find_summary_for_ident(ident, cnx: cnx)
        end

      value = matched_summary ? matched_summary[primary_id_key] : nil

      raise Windoo::NoSuchItemError, "No #{self} found for identifier '#{ident}'" if raise_if_not_found && value.nil?

      value
    end

    ####
    def self.find_summary_for_ident(ident, cnx: Windoo.cnx)
      all(cnx: cnx).each do |summary|
        ident_keys.each do |key|
          return summary if summary[key] == ident
        end
      end
      nil
    end
    private_class_method :find_summary_for_ident

    # Get the 'autofill patches' for a given software title
    #
    # @param ident [String, Integer] An identifier for a software title
    #
    # @return [Array<Hash>] the autofill patch data
    ####
    def self.autofill_patches(ident, cnx: Windoo.cnx)
      id = valid_id ident, raise_if_not_found: true, cnx: cnx

      cnx.get("#{self::RSRC_PATH}/#{id}/patches/autofill")
    end

    # Get the 'autofill requirements' for a given software title
    #
    # @param ident [String, Integer] An identifier for a software title
    #
    # @return [Array<Hash>] the autofill requirement data
    ####
    def self.autofill_requirements(ident, cnx: Windoo.cnx)
      id = valid_id ident, raise_if_not_found: true, cnx: cnx

      cnx.get("#{self::RSRC_PATH}/#{id}/requirements/autofill")
    end

    # Attributes
    ######################

    # Attributes not defined in the superclasses

    JSON_ATTRIBUTES = {

      # @!attribute softwareTitleId
      #   @return [Integer] The id of this title in the Title Editor
      softwareTitleId: {
        class: :Integer,
        # primary means this is the one used to fetch via API calls
        identifier: :primary,
        readonly: true,
        do_not_send: true
      },

      # @!attribute id
      # @return [String] A string, unique any patch source (in this case
      #   the TitleEditor), that identifies this Software Title.
      #   Can be thought of as the unique name on the Title Editor.
      #   Not to be confused with the 'name' attribute, which is more
      #   of a Display Name, and is not unique
      id: {
        class: :String,
        # true means this is a unique value in and can be used to find a valid
        # primary identifier.
        identifier: true,
        # required means this value is required to create or update this
        # object on the server(s)
        required: true
      },

      # @!attribute enabled
      #   @return [Boolean] Is this title enabled, and available to be subscribed to?
      enabled: {
        class: :Boolean
      },

      # @!attribute name
      #   @return [String] The name of this title in the Title Editor. NOT UNIQUE,
      #     and not an identfier. See 'id'.
      name: {
        class: :String,
        required: true
      },

      # @!attribute publisher
      #   @return [String] The publisher of this software
      publisher: {
        class: :String,
        required: true
      },

      # @attribute appName
      #   @return [String] Currently not used by the Title Editor
      #      or Jamf Pro Patch Titles.
      #      There is no matching data in the Web UI.
      #      These data exist in the killApps associated with Patches
      appName: {
        class: :String
      },

      # @attribute bundleId
      #   @return [String] Currently not used by the Title Editor
      #      or Jamf Pro Patch Titles.
      #      There is no matching data in the Web UI.
      #      These data exist in the killApps associated with Patches
      bundleId: {
        class: :String
      },

      # @!attribute lastModified
      #   @return [Time]  When was the title last modified, in UTC?
      #     @note This timestamp is only valid as of the last time
      #       you fetched this SoftwareTitle or updated one of its
      #       immediate attributes (i.e. not arrays of other API
      #       objects like requirements or patches.)
      #       To be sure of the most recent time, accounting for
      #       potential updates from other places (like the Web UI)
      #       you should re-fetch the Title
      lastModified: {
        class: :Time,

        # for classes (like Time) that are not Symbols (like :String)
        # This is the Class method to call on them to convert the
        # raw API data into the ruby value we want. The API data
        # will be passed as the sole param to this method.
        # For most, it will be :new, but for, e.g., Time, it is
        # :parse
        to_ruby: :to_time,

        # The method to call on the value when converting to
        # data to be sent to the API.
        # e.g. on Time values, convert to iso8601
        # to_api: :iso8601

        # attributes with this set to true are never
        # sent to the server when creating or updating
        do_not_send: true,
        readonly: true
      },

      # @!attribute currentVersion
      #   @return [String] the version number of the most recent patch
      currentVersion: {
        class: :String,
        required: true
      },

      # This value only appears in the .all summary hash, not in the
      # full instance init_data.
      #
      # _!attribute source
      # _return [String] The name of the Patch Source that ultimately
      #   hosts this title definition. If hosted by our TitleEditor
      #   directly, this is LOCAL_TITLE_EDITOR_SOURCE_NAME
      #
      #   @todo implement external patches.
      # source: {
      #   class: :String
      # },

      # @!attribute sourceId
      # @return [Integer] The id of the Patch Source that ultimately
      #   hosts this title definition. If hosted by our TitleEditor
      #   directly, this is LOCAL_TITLE_EDITOR_SOURCE_ID
      #
      #   @todo implement external patches.
      # sourceId: {
      #   class: :Integer,
      #   do_not_send: true
      # },

      # @!attribute requirements
      #   @return [Array<Windoo::Requirement>] The requirements - criteria that
      #     define which computers have the software installed.
      requirements: {
        class: Windoo::RequirementManager,
        do_not_send: true,
        readonly: true
      },

      # @!attribute patches
      #   @return [Array<Windoo::Patch>] The patches available for this title
      patches: {
        class: Windoo::PatchManager,
        do_not_send: true,
        readonly: true
      },

      # @!attribute extensionAttributes
      #   @return [Windoo::ExtensionAttribute] The Extension Attribute used by this title.
      #     NOTE: See the module Windoo::Mixins::SoftwareTitle::ExtentionAttribute
      extensionAttribute: {
        class: Windoo::ExtensionAttribute,
        do_not_send: true,
        readonly: true
      }
    }.freeze

    # Construcor
    ######################
    def initialize(**init_data)
      super

      @requirements = Windoo::RequirementManager.new @requirements, container: self
      @patches = Windoo::PatchManager.new @patches, container: self
    end

    # Public Instance Methods
    ###################################

    # Get the 'autofill patches' for this software title
    # @return [Array<Hash>] the autofill patch data
    def autofill_patches
      id = send self.class.primary_id_key
      self.class.autofill_patches id
    end

    # Get the 'autofill requirements' for this software title
    # @return [Array<Hash>] the autofill requirement data
    def autofill_requirements
      id = send self.class.primary_id_key
      self.class.autofill_requirements id
    end

    # Enable this SoftwareTitle
    def enable
      return if enabled?

      if requirements.empty? || patches.all_enabled.empty?
        raise Windoo::MissingDataError,
              'SoftwareTitles must have at least one requirement and one enabled patch before they can be enabled'
      end

      self.enabled = true
      :enabled
    end

    # Disable this SoftwareTitle
    def disable
      return unless enabled?

      self.enabled = false
      :disabled
    end

    # Update our modification timestamp from other objects
    # to the current time when they are changed on the server.
    def update_modification_time
      @lastModified = Time.now.utc
    end

    # Private Instance Methods
    ##########################################
    private

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_create_response(post_response, container_id: nil)
      @softwareTitleId = post_response[:softwareTitleId]

      @sourceId = post_response[:sourceId]
      @enabled = post_response[:enabled]

      @softwareTitleId
    end

    # See the section 'REQUIRED ITEMS WHEN MIXING IN'
    # in the APICollection mixin.
    def handle_update_response(_put_response)
      @softwareTitleId
    end

  end # class SoftwareTitle

end # Module Windoo
