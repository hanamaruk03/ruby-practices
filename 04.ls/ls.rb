#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 3

def main
  options = parse_options
  items = fetch_sorted_items(reversed: options[:r])
  formatted_rows = build_horizontal_rows(items)
  print_grid(formatted_rows)
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-r') { |v| options[:r] = v }
  opt.parse!(ARGV)
  options
end

def fetch_sorted_items(reversed: false)
  items = Dir.glob('*').sort
  items.reverse! if reversed
  items
end

def build_horizontal_rows(items)
  items += [nil] while items.count % COLUMN_SIZE != 0

  row_size = items.count / COLUMN_SIZE

  items.each_slice(row_size).filter_map do |row|
    next if row.all?(&:nil?)

    width = row.compact.max_by(&:length).length
    adjust_width(row, width)
  end
end

def print_grid(horizontal_rows)
  horizontal_rows.transpose.each do |file_names|
    puts file_names.compact.join('  ')
  end
end

def adjust_width(row, width)
  row.map do |file_name|
    file_name&.ljust(width)
  end
end

main
