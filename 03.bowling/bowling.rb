#!/usr/bin/env ruby
# frozen_string_literal: true

BLANK_SHOT = nil
LAST_SHOT = 19

def strike?(shots, shot_index)
  shots[shot_index] == 10
end

def spare?(shots, shot_index)
  shots[shot_index, 2].sum == 10
end

knocked_down_pins = ARGV[0].split(',')
shots = []

knocked_down_pins.each do |pin|
  if pin == 'X'
    shots << 10
    shots << BLANK_SHOT if shots.count < LAST_SHOT
  else
    shots << pin.to_i
  end
end

point = 0

(0..18).step(2) do |shot_index|
  point +=
    if strike?(shots, shot_index)
      shots.drop(shot_index).compact.first(3).sum
    elsif spare?(shots, shot_index)
      shots[shot_index, 3].sum
    else
      shots[shot_index, 2].sum
    end
end

p point
