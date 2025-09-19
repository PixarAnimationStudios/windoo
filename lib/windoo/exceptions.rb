# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Windoo

  # Connections & Access

  class ConnectionError < RuntimeError; end

  class NotConnectedError < RuntimeError; end

  class AuthenticationError < RuntimeError; end

  class PermissionError < RuntimeError; end

  class InvalidTokenError < RuntimeError; end

  # General errors

  class MissingDataError < RuntimeError; end

  class InvalidDataError < RuntimeError; end

  class NoSuchItemError < RuntimeError; end

  class AlreadyExistsError < RuntimeError; end

  class UnsupportedError < RuntimeError; end

end # module Windoo
