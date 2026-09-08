#!/usr/bin/env ruby
# frozen_string_literal: true

knocked_down_pins = ARGV[0].split(',')
shots = []
BLANK_SHOT = nil
knocked_down_pins.each do |pin|
  if pin == 'X'
    shots << 10
    # 10フレーム目（20投目より前）まではストライクした場合2投目をBLANK_SHOTにする
    if shots.count < 19
      shots << BLANK_SHOT
    end
  else
    shots << pin.to_i
  end
end

point = 0

(0..18).step(2) do |shot_index|
  point +=
    if shots[shot_index + 1] == BLANK_SHOT
      if shots[shot_index + 3] == BLANK_SHOT
        shots[shot_index] + shots[shot_index + 2] + shots[shot_index + 4]
      else
        shots[shot_index] + shots[shot_index + 2] + shots[shot_index + 3]
      end
    elsif shots[shot_index] + shots[shot_index + 1] == 10
      shots[shot_index] + shots[shot_index + 1] + shots[shot_index + 2]
    else
      shots[shot_index] + shots[shot_index + 1]
    end
end

p point
