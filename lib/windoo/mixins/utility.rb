# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.

# frozen_string_literal: true

module Windoo

  module Mixins

    # This should be extended into the Windoo module
    module Utility

      def self.extended(extender)
        Windoo.verbose_extend extender, self
      end

    end # Utility

  end #  module Mixins

end # Windoo
