#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'
require 'etc'

COLUMN_SIZE = 3
BYTE_ARRAY = 4

def main
  options = parse_options

  formatted_rows =
    if options[:l]
      total_blocks = calculate_blocks(catch_objects.transpose[BYTE_ARRAY])
      puts "total #{total_blocks}"

      items = catch_objects.transpose
      items.map.with_index do |row, i|
        width = row.max_by(&:length).length
        lr = i != BYTE_ARRAY ? :left : :right
        adjust_width(row, width, lr)
      end
    else
      items = Dir.glob('*').sort
      build_horizontal_rows(items)
    end
  print_grid(formatted_rows.transpose)
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  opt.parse!(ARGV)
  options
end

def catch_objects
  objects = Pathname.glob('*')
  check_files(objects)
end

def check_files(objects)
  objects.map do |detail_datas|
    [
      judge_type(detail_datas) + change_mode_to_aurthority(detail_datas.stat.mode),
      detail_datas.stat.nlink.to_s,
      Etc.getpwuid(detail_datas.stat.uid).name,
      Etc.getgrgid(detail_datas.stat.gid).name,
      detail_datas.size.to_s,
      detail_datas.mtime.strftime('%b %d %H:%M'),
      detail_datas.basename.to_s
    ]
  end
end

def calculate_blocks(byte_array)
  byte_array.map do |byte|
    unit_count = (byte.to_f / 4096.0).ceil
    unit_count * 4
  end.sum
end

def change_mode_to_aurthority(mode)
  authority = {
    '000' => '---',
    '001' => '--x',
    '010' => '-w-',
    '011' => '-wx',
    '100' => 'r--',
    '101' => 'r-x',
    '110' => 'rw-',
    '111' => 'rwx'
  }
  mode.to_s(2)[-9, 9].scan(/.{1,3}/).map do |n|
    authority[n]
  end.join
end

def judge_type(object)
  if object.file?
    '-'
  elsif object.directory?
    'd'
  elsif object.symlink?
    'l'
  end
end

def build_horizontal_rows(items)
  items += [nil] while items.count % COLUMN_SIZE != 0

  row_size = items.count / COLUMN_SIZE

  items.each_slice(row_size).filter_map do |row|
    next if row.all?(&:nil?)

    width = row.compact.max_by(&:length).length
    adjust_width(row, width, :left)
  end
end

def print_grid(horizontal_rows)
  horizontal_rows.each do |file_names|
    puts file_names.compact.join(' ')
  end
end

def adjust_width(row, width, which_side)
  case which_side
  when :left  then row.map { |f| f&.ljust(width) }
  when :right then row.map { |f| f&.rjust(width) }
  end
end

main
