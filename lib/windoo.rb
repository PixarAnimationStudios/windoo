# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

# Core Standard Libraries
######
require 'English'
require 'time'

# Other gems
######
require 'pixar-ruby-extensions'
require 'faraday' # >= 0.17.0

# Zeitwerk
######

# Configure the Zeitwerk loader, See https://github.com/fxn/zeitwerk
# This also defines other methods related to loading
require 'windoo/zeitwerk_config'

# the `Zeitwerk::Loader.for_gem` creates the loader object, and must
# happen in this file, so we pass it into a method defined in
# zeitwerk_config
#
# BE CAREFUL - Do not load anything above here that
# defines the Windoo:: module namespace!
WindooZeitwerkConfig.setup_zeitwerk_loader Zeitwerk::Loader.for_gem

# Zeitwerk
######

# Load windoo stuff here that we don't autoload with zeitwerk
require 'windoo/exceptions'

# The main module
module Windoo

  extend Windoo::Mixins::Loading
  include Windoo::Mixins::Constants
  extend Windoo::Mixins::Utility
  extend Windoo::Mixins::DefaultConnection

  # the single instance of our configuration object
  def self.config
    Windoo::Configuration.instance
  end

end # module Windoo

# testing zeitwerk loading, if the correct file is present
WindooZeitwerkConfig.eager_load_for_testing

# Set a default user-agent for Faraday requests
# do thise after zeitwerk has loaded Constants
Faraday.default_connection_options = { headers: { user_agent: "windoo/#{Windoo::VERSION} Faraday/#{Faraday::VERSION}" } }
