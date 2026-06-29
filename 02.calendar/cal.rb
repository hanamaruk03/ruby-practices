#!/usr/bin/env ruby

require "date"
require "optparse"

year = Date.today.year
month = Date.today.month

opt = OptionParser.new

opt.on('-y YEAR'){|v| year = v.to_i}
opt.on('-m MONTH'){|v| month = v.to_i}

opt.parse!(ARGV)

check_last_date = Date.new(year, month, -1)
last_day = check_last_date.day
wday = Date.new(year, month, 1).wday

week1 = []
if wday != 0
  week1.push(("  ") + ("   " * (wday - 1)))
end

(1..last_day).each {|num|
  if (num + wday) % 7 == 0
    week1.push(num.to_s.rjust(3) + "\n")
  elsif Date.new(year, month, num).wday == 0
    week1.push(num.to_s.rjust(2))
  else
    week1.push(num.to_s.rjust(3))
  end
}

puts "#{year}年 #{month}月".center(18)
puts "日 月 火 水 木 金 土"
puts week1.join
