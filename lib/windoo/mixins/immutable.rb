# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

# main module
module Windoo

  module Mixins

    # by default, instances of JSONObject subclasses are mutable
    # as a whole, even if some of their attributes are not.
    #
    # To make them immutable, they should extend this module
    #    Windoo::Mixins::Immutable,
    # which overrides the mutable? method
    module Immutable

      def self.extended(extender)
        Windoo.verbose_extend extender, self
      end

      # this class is immutable
      def mutable?
        false
      end

    end # module Immutable

  end # module Mixins

end # module Windoo
