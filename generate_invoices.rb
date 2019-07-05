# frozen_string_literal: true

require 'pathname'
require 'automatic_sat'

class FileIterator
  attr_reader :file_names

  def initialize(file_names)
    @file_names = file_names
    check_for_files
  end

  def iterate
    file_names.each do |file_name|
      yield file_name
    end
  end

  private

  def check_for_files
    file_names.each do |file_name|
      raise Errno::ENOENT, "File #{file_name} not found" unless file_exist? file_name
    end
  end

  def file_exist?(file_name)
    Pathname.new(file_name).exist?
  end
end

args = ARGV

file_iterator = FileIterator.new(args)

file_iterator.iterate do |file_name|
  AutomaticSat.new(file_name).generate_invoices
end
