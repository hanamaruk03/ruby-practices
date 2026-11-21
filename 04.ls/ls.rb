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

  rows =
    if options[:l]
      entries = extract_file_entries
      total_blocks = count_total_blocks(entries)
      puts "total #{total_blocks}"

      format_entry(entries)
    else
      items = Dir.glob('*').sort
      build_horizontal_rows(items).transpose
    end
  print_grid(rows)
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  opt.parse!(ARGV)
  options
end

def extract_file_entries
  Pathname.glob('*').map do |pathname|
    {
      type_and_authority: entry_type(pathname) + change_mode_to_permission(pathname.stat.mode),
      nlink: pathname.stat.nlink,
      owner_name: Etc.getpwuid(pathname.stat.uid).name,
      group_name: Etc.getgrgid(pathname.stat.gid).name,
      size: pathname.size,
      modification_time: pathname.mtime.strftime('%b %d %H:%M'),
      file_name: pathname.basename
    }
  end
end

def format_entry(entries)
  widths = Hash.new(0)
  entries.each do |details|
    details.each { |key, value| widths[key] = [widths[key], value.to_s.length].max }
  end
  rjust_symbols = %i[nlink size]
  entries.map do |details|
    details.map do |key, value|
      rjust_symbols.include?(key) ? value.to_s.rjust(widths[key]) : value.to_s.ljust(widths[key])
    end
  end
end

def count_total_blocks(entries)
  entries.sum do |item_details|
    unit_count = item_details[:size].ceildiv(BLOCK_SIZE)
    unit_count * KB_PER_BLOCK
  end
end

def change_mode_to_permission(mode)
  mode.to_s(2)[-9..].gsub(/.{1,3}/, AUTHORITY)
end

def entry_type(entry)
  if entry.directory?
    'd'
  elsif entry.symlink?
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

def print_grid(rows)
  rows.each do |row|
    puts row.compact.join(' ')
  end
end

main
