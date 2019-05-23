# frozen_string_literal: true

require 'pathname'

class AutomaticSat::FileSearcher
  def self.child_directories(pathname)
    pathname.children.select(&:directory?)
  end

  def self.find_certificate(pathname)
    find_by_extension(pathname, '.cer')
  end

  def self.find_private_key(pathname)
    find_by_extension(pathname, '.key')
  end

  def self.find_private_key_password(pathname)
    find_by_extension(pathname, '.pass')
  end

  def self.find_by_extension(pathname, extension)
    pathname.children.detect { |child| child.extname == extension }
  end

  def self.find_by_name(pathname, name)
    pathname.children.detect { |child| child.basename.to_s == name }
  end
end
