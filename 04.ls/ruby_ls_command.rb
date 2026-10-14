#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_SIZE = 3

def main
  items = Dir.children(Dir.getwd).sort
  items += [nil] while items.count % COLUMN_SIZE != 0

  row_size = items.count / COLUMN_SIZE

  horizontal_rows =
    items.each_slice(row_size).filter_map do |row|
      next if row.all?(&:nil?)

      width = row.compact.max_by(&:length).length
      adjust_width(row, width)
    end

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
