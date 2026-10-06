#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_WIDTH = 3
PARTITION_BLANK = 2

def main
  formatted_items = format_array(Dir.children(Dir.getwd).sort)

  row_size = formatted_items.count / COLUMN_WIDTH

  horizontal_rows = []

  formatted_items.each_slice(row_size) do |row|
    next if row.all?(&:nil?)

    display_width = row.compact.max { |file_name_a, file_name_b| file_name_a.length <=> file_name_b.length }.length
    horizontal_rows << adjust_width(row, display_width)
  end

  results_array = horizontal_rows.transpose

  results_array.each do |file_name|
    puts file_name.compact.join(' ' * PARTITION_BLANK)
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
