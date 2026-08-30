#!/usr/bin/env ruby
# frozen_string_literal: true

scores = ARGV[0].split(',')
shots = []
scores.each do |s|
  if shots.count < 19
    if s == 'X'
      shots << 10
      shots << 'a'
    else
      shots << s.to_i
    end
  else
    shots <<
      if s == 'X'
        10
      else
        s.to_i
      end
  end
end

point = 0

(0..18).step(2) do |v|
  point +=
    if shots[v + 1] == 'a'
      if shots[v + 3] == 'a'
        shots[v] + shots[v + 2] + shots[v + 4]
      else
        shots[v] + shots[v + 2] + shots[v + 3]
      end
    elsif shots[v] + shots[v + 1] == 10
      shots[v] + shots[v + 1] + shots[v + 2]
    else
      shots[v] + shots[v + 1]
    end
end

p point
