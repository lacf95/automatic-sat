# frozen_string_literal: true

require 'pathname'
require 'automatic_sat'

args = ARGV

file_iterator = AutomaticSat::FileIterator.new(args)

file_iterator.iterate do |file_name|
  AutomaticSat.new(file_name).generate_taxes_return
end
