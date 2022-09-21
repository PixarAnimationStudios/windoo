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

module Windu

  # A Software Title in the Title Editor
  class SoftwareTitle < Windu::BaseClasses::JSONObject

    # Mixins
    ######################

    include Windu::Mixins::APICollection

    # Constants
    ######################

    LOCAL_TITLE_EDITOR_SOURCE_NAME = 'Local'
    LOCAL_TITLE_EDITOR_SOURCE_ID = 0

    RSRC_PATH = 'softwaretitles'

    # when creating or updating this object itself, only these attributes are sent.
    # Sub-objects are saved or updated via #create_x methods (e.g. create_patch)
    # or by calling save on existing objects inside this SoftwareTitle,
    # (e.g. #patches[3].save)
    # NOTE: the docs also mention that this data for create and update has
    # keys 'appName' and 'bundleId'  but those keys don't show up in the
    # web UI and are always nil in the API data.
    ATTRIBUTES_FOR_SAVE = %i[
      id
      name
      publisher
      enabled
      lastModified
      currentVersion
    ].freeze

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
    # :patches=>0,  # Number of enabled patches, not existing patches.
    # :id=>"com.somecompany.test",
    # :sourceId=>0,
    # :source=>"Local"
    #
    # @return [Array<Hash>]
    ####
    def self.all
      Windu.cnx.get(self::RSRC_PATH)
    end

    # @return [Windu::SoftwareTitle]
    ####
    def self.fetch(ident = nil, **key_and_ident)
      raise ArgumentError, "ident, or 'key: ident' is required to fetch" unless ident || !key_and_ident.empty?

      id =
        if ident
          valid_id ident, raise_if_not_found: true
        else
          key, ident = key_and_ident.first

          # Dont call valid_id if we are fetching based on the primary_ident_key
          # just used the value provided. The API will complain if it
          # doesn't exist
          key == primary_ident_key ? ident : valid_id(ident, key: key, raise_if_not_found: true)
        end

      new Windu.cnx.get("#{self::RSRC_PATH}/#{id}")
    end

    # @param ident [Integer, String] the identifier value to search for
    #
    # @param key [Symbol] if given, Only look for the value in this key.
    #
    # @return [Integer, nil] given any identifier, return the matching primary id
    #   or nil if no match
    ####
    def self.valid_id(ident, key: nil, raise_if_not_found: false)
      matched_summary =
        if key
          all.select { |summary| summary[key] == ident }.first
        else
          find_summary_for_ident(ident)
        end

      value = matched_summary ? matched_summary[primary_ident_key] : nil

      raise Windu::NoSuchItemError, "No #{self} found for identifier '#{ident}'" if raise_if_not_found && value.nil?

      value
    end

    ####
    def self.find_summary_for_ident(ident)
      all.each do |summary|
        ident_keys.each do |key|
          return summary if summary[key] == ident
        end
      end
      nil
    end
    private_class_method :find_summary_for_ident

    # Get the 'autofill patches' for a given software title
    # @param ident [String, Integer] An identifier for a software title
    # @return [Array<Hash>] the autofill patch data
    def self.autofill_patches(ident)
      id = valid_id ident, raise_if_not_found: true

      Windu.cnx.get("#{self::RSRC_PATH}/#{id}/patches/autofill")
    end

    # Get the 'autofill requirements' for a given software title
    # @param ident [String, Integer] An identifier for a software title
    # @return [Array<Hash>] the autofill requirement data
    def self.autofill_requirements(ident)
      id = valid_id ident, raise_if_not_found: true

      Windu.cnx.get("#{self::RSRC_PATH}/#{id}/requirements/autofill")
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
        identifier: :primary
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

      # @!attribute lastModified
      #   @return [Time]  When was the title last modified?
      lastModified: {
        class: Time,

        # for classes (like Time) that are not Symbols (like :String)
        # This is the Class method to call on them to convert the
        # raw API data into the ruby value we want. The API data
        # will be passed as the sole param to this method.
        # For most, it will be :new, but for, e.g., Time, it is
        # :parse
        to_ruby: :parse,

        # The method to call on the value when converting to
        # data to be sent to the API.
        # e.g. on Time values, convert to iso8601
        to_api: :iso8601
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
      # source: {
      #   class: :String
      # },

      # @!attribute sourceId
      # @return [Integer] The id of the Patch Source that ultimately
      #   hosts this title definition. If hosted by our TitleEditor
      #   directly, this is LOCAL_TITLE_EDITOR_SOURCE_ID
      sourceId: {
        class: :Integer
      },

      # @!attribute requirements
      #   @return [Array<Windu::BaseClasses::Requirement>] The requirements - criteria that
      #     define which computers have the software installed.
      requirements: {
        class: Windu::Requirement,
        multi: true
      },

      # @!attribute patches
      #   @return [Array<Windu::BaseClasses::Patch>] The patches available for this title
      patches: {
        class: Windu::Patch,
        multi: true
      },

      # @!attribute extensionAttributes
      #   @return [Array<Windu::BaseClasses::ExtensionAttribute>] The Extension Attributes used by this title
      extensionAttributes: {
        class: Windu::ExtensionAttribute,
        multi: true
      }
    }.freeze

    # Construcor
    ######################
    def initialize(_json_data)
      super
      @requirements = requirements.map { |data| Windu::Requirement.new data }
      @patches = patches.map { |data| Windu::Patch.new data }
      @extensionAttributes = extensionAttributes.map do |data|
        Windu::ExtensionAttribute.new data
      end
    end

    # Public Instance Methods
    ###################################

    # Get the 'autofill patches' for this software title
    # @return [Array<Hash>] the autofill patch data
    def autofill_patches
      id = send self.class.primary_ident_key
      self.class.autofill_patches id
    end

    # Get the 'autofill requirements' for this software title
    # @return [Array<Hash>] the autofill requirement data
    def autofill_requirements
      id = send self.class.primary_ident_key
      self.class.autofill_requirements id
    end

  end # class SoftwareTitle

end # Module Windu
