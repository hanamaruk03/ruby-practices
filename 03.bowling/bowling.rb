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
BLANK_SHOT = nil
knocked_down_pins.each do |pin|
  if pin == 'X'
    shots << 10
    # 10フレーム目（20投目より前）まではストライクした場合2投目をBLANK_SHOTにする
    shots << BLANK_SHOT if shots.count < 19
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
