require "singleton"
require "fileutils"

module Zomgit
  class Persistor
    attr_reader :index, :indexed, :index_file
    alias_method :indexed?, :indexed

    RUNTIME_DIR = File.expand_path(File.join(ENV["HOME"], ".zomgit"))
    INDEXES_DIR = File.join(RUNTIME_DIR, "indexes")

    include Singleton

    def initialize
      unless File.directory?(RUNTIME_DIR)
        FileUtils.mkdir_p([RUNTIME_DIR, INDEXES_DIR])
      end

      if File.file?(self.index_file)
        @index = File.read(self.index_file).split("\n")
        @indexed = true
      else
        @index = []
        @indexed = false
      end
    end

    def cache_index(files)
      @index = files

      File.open(self.index_file, "wb") { |f| f.puts files.join("\n") }

      @indexed = true
    end

    def clean_index_cache!
      if self.indexed?
        File.unlink(self.index_file)
        @indexed = false
      end
    end

    def index_file
      unless @index_file
        @index_file = File.join(INDEXES_DIR, Zomgit::project_root.gsub(/#{Regexp.escape(File::SEPARATOR)}/, "~~"))
      end

      @index_file
    end
  end
end
