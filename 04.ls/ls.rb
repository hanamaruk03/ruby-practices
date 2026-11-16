#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'
require 'etc'

COLUMN_SIZE = 3
BYTE_ARRAY = 4
BLOCK_SIZE = 4096
KB_PER_BLOCK = 4

AUTHORITY = {
  '000' => '---',
  '001' => '--x',
  '010' => '-w-',
  '011' => '-wx',
  '100' => 'r--',
  '101' => 'r-x',
  '110' => 'rw-',
  '111' => 'rwx'
}.freeze

def main
  options = parse_options

  formatted_rows =
    if options[:l]
      items = extract_file_data
      total_blocks = count_total_blocks(items)
      puts "total #{total_blocks}"

      items.map(&:values)
    else
      items = Dir.glob('*').sort
      build_horizontal_rows(items).transpose
    end
  print_grid(formatted_rows)
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  opt.parse!(ARGV)
  options
end

def extract_file_data
  width = { type_and_authority: 0,
            nlink: 0,
            owner_name: 0,
            owner_groupe_name: 0,
            size: 0,
            modification_date_and_time: 0,
            file_name: 0 }

  items = Pathname.glob('*').map do |item|
    item_details = { type_and_authority: entry_type(item) + change_mode_to_aurthority(item.stat.mode),
                     nlink: item.stat.nlink.to_s,
                     owner_name: Etc.getpwuid(item.stat.uid).name,
                     owner_groupe_name: Etc.getgrgid(item.stat.gid).name,
                     size: item.size.to_s,
                     modification_date_and_time: item.mtime.strftime('%b %d %H:%M'),
                     file_name: item.basename.to_s }
    item_details.each { |key, value| width[key] = [width[key], value.length].max }
    item_details
  end
  items.map { |item_details| item_details.to_h { |key, value| [key, %i[nlink size].include?(key) ? value.rjust(width[key]) : value.ljust(width[key])] } }
end

def count_total_blocks(file_data)
  file_data.map do |item_details|
    unit_count = item_details[:size].to_i.ceildiv(BLOCK_SIZE)
    unit_count * KB_PER_BLOCK
  end.sum
end

def change_mode_to_aurthority(mode)
  mode.to_s(2)[-9, 9].gsub(/.{1,3}/, AUTHORITY)
end

def entry_type(object)
  if object.directory?
    'd'
  elsif object.symlink?
    'l'
  else
    '-'
  end
end

def build_horizontal_rows(items)
  items += [nil] while items.count % COLUMN_SIZE != 0

  row_size = items.count / COLUMN_SIZE

  items.each_slice(row_size).filter_map do |row|
    next if row.all?(&:nil?)

    width = row.compact.max_by(&:length).length
    row.map { |f| f&.ljust(width) }
  end
end

def print_grid(horizontal_rows)
  horizontal_rows.each do |file_names|
    puts file_names.compact.join(' ')
  end
end

main
