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

# Core Standard Libraries
######
require 'English'

# Load other gems
######
require 'pixar-ruby-extensions'
require 'faraday' # >= 0.17.0
require 'faraday_middleware' # >= 0.13.0

# Zeitwerk
######

# Configure the Zeitwerk loader, See https://github.com/fxn/zeitwerk
# This also defines other Windu module methods related to loading
#
require 'windu/zeitwerk_config'

# the `Zeitwerk::Loader.for_gem` creates the loader object, and must
# happen in this file, so we pass it into a method defined in
# zeitwerk_config
#
# BE CAREFUL - Do not load anything above here that
# defines the Windu:: module namespace!
WinduZeitwerkConfig.setup_zeitwerk_loader Zeitwerk::Loader.for_gem

# Load windu stuff here that we don't autoload
require 'windu/exceptions'

# The main module
module Windu

  extend Windu::Loading
  include Windu::Constants
  extend Windu::Utility
  extend Windu::API::DefaultConnection

  # the single instance of our configuration object
  def self.config
    Windu::Configuration.instance
  end

end # module Windu

# testing zeitwerk loading, if the correct file is present
WinduZeitwerkConfig.eager_load_for_testing
