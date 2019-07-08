# frozen_string_literal: true

require 'pathname'

class AutomaticSat::FileSearcher
  class << self
    def child_directories(pathname)
      pathname.children.select(&:directory?)
    end

    def find_certificate(pathname)
      find_by_extension(pathname, '.cer')
    end

    def find_private_key(pathname)
      find_by_extension(pathname, '.key')
    end

    def find_private_key_password(pathname)
      find_by_extension(pathname, '.pass')
    end

    def find_by_extension(pathname, extension)
      found = pathname.children.detect { |child| child.extname == extension }
      raise Errno::ENOENT, "File with extension #{extension} not found in #{pathname}" unless found

      found
    end

    def find_by_name(pathname, name)
      found = pathname.children.detect { |child| child.basename.to_s == name }
      raise Errno::ENOENT, "File or diirectory #{pathname.join(name)} not found" unless found

      found
    end
  end
end
