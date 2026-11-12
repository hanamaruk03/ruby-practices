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
      total_blocks = count_total_blocks(extract_file_data)
      puts "total #{total_blocks}"

      extract_file_data.map(&:values)
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
            count_hardlink: 0,
            owner_name: 0,
            owner_groupe_name: 0,
            size: 0,
            modification_date_and_time: 0,
            file_name: 0 }
  items = Pathname.glob('*')

  items.map! do |detail_datas|
    hash = { type_and_authority: entry_type(detail_datas) + change_mode_to_aurthority(detail_datas.stat.mode),
             count_hardlink: detail_datas.stat.nlink.to_s,
             owner_name: Etc.getpwuid(detail_datas.stat.uid).name,
             owner_groupe_name: Etc.getgrgid(detail_datas.stat.gid).name,
             size: detail_datas.size.to_s,
             modification_date_and_time: detail_datas.mtime.strftime('%b %d %H:%M'),
             file_name: detail_datas.basename.to_s }
    hash.each { |key, value| width[key] = [width[key], value.length].max }
    hash.to_h { |key, value| [key, key != :size ? value.ljust(width[key]) : value.rjust(width[key])] }
  end
end

def count_total_blocks(file_data)
  file_data.map do |hash|
    unit_count = hash[:size].to_i.ceildiv(BLOCK_SIZE)
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
