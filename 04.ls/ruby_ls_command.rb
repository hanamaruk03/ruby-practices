#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_WIDTH = 3

def main
  items = Dir.children(Dir.getwd).sort
  formatted_items = pack_nils(items)

  row_size = formatted_items.count / COLUMN_WIDTH

  horizontal_rows = []

  formatted_items.each_slice(row_size) do |row|
    next if row.all?(&:nil?)

    display_width = row.compact.max_by(&:length).length
    horizontal_rows << adjust_width(row, display_width)
  end

  results = horizontal_rows.transpose

  results.each do |file_names|
    puts file_names.compact.join('  ')
  end
end

def adjust_width(row, width)
  row.map do |file_name|
    next if file_name.nil?

    file_name.ljust(width)
  end
end

def format_array(target)
  target += nil while target.count % COLUMN_WIDTH != 0
  target
end

main
