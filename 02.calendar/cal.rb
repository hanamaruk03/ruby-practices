#!/usr/bin/env ruby

require "date"
require "optparse"

year = Date.today.year
month = Date.today.month

opt = OptionParser.new

opt.on('-y YEAR'){|v| year = v.to_i}
opt.on('-m MONTH'){|v| month = v.to_i}

opt.parse!(ARGV)

first_day = Date.new(year, month, 1)
last_day = Date.new(year, month, -1)

week1 = []

puts "#{year}年 #{month}月".center(18)
puts "日 月 火 水 木 金 土"
print (['   '] * first_day.wday).join

(first_day..last_day).each {|date|
  week1.push(date.day.to_s.rjust(2))
  if date.saturday?
    puts week1.join(' ')
    week1 = []
  end
}

puts week1.join(' ')
