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
week1.push("   " * wday)

(1..last_day).each {|num|
  if num <= 9
    week1.push(" ")
  end
  if (num + wday) % 7 == 0
    week1.push(num.to_s + " \n")
  else
    week1.push(num.to_s + " ")
  end
}

print "   #{year}年 #{month}月   \n"
print "日 月 火 水 木 金 土 \n"
print week1.join + "\n"