# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#

# frozen_string_literal: true

module Windoo

  module Mixins

    module Loading

      def self.extended(extender)
        Windoo.verbose_extend extender, self
      end

      # Use the load_msg method defined for Zeitwerk
      def load_msg(msg)
        WindooZeitwerkConfig.load_msg msg
      end

      # Mention that a module is being included into something
      def verbose_include(includer, includee)
        load_msg "--> #{includer} is including #{includee}"
      end

      # Mention that a module is being extended into something
      def verbose_extend(extender, extendee)
        load_msg "--> #{extender} is extending #{extendee}"
      end

    end # module Loading

  end #   module Mixins

end # module Windoo
