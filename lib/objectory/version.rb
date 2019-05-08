module Objectory

  class Version

    def initialize(version = nil)
      @version = version || find_version
    end

    def to_s
      @version
    end

    private

    def find_version
      read_version_from_env || read_version_from_file
    end

    def read_version_from_env
      ENV['OBJECTORY_VERSION']
    end

    def read_version_from_file
      File.read(
        File.expand_path(
          'VERSION',
          File.join(
            File.dirname(__dir__), '../'
          )
        )
      ).chomp
    end

  end

  VERSION = Version.new.to_s

end
