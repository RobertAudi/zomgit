module Zomgit
  module Exceptions
    #
    # Base exception
    #
    class BaseError < ArgumentError; end

    #
    # Global exceptions
    #
    class NoGitRepoFoundError < BaseError; end
    class InvalidOptionError < BaseError; end

    #
    # Status command exceptions
    #
    class TooManyChangesError < BaseError; end
    class NoChangesError < BaseError; end
    class InvalidFilterError < BaseError; end

    #
    # Add command exceptions
    #
    class FileOrDirectoryNotFoundError < BaseError; end
  end
end
