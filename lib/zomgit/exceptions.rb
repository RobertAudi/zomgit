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
    class NoChangesError < BaseError; end

    #
    # Indices exceptions
    #
    class NoIndexError < BaseError; end
    class InvalidIndexError < BaseError; end
    class InvalidIndexRangeError < BaseError; end

    #
    # Status command exceptions
    #
    class TooManyChangesError < BaseError; end

    #
    # Find command exceptions
    #
    class MissingQueryError < BaseError; end

    #
    # Add command exceptions
    #
    class FileOrDirectoryNotFoundError < BaseError; end
  end
end
