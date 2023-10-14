// orbit script to go with firstorb ship design.
// This is hardcoded to only work with that specific design.

core:doevent("Open Terminal").
print "Press Any Key to Start Launch.".
set ch to terminal:input:getchar().
print "Here We Go!".

clearscreen.

set pit to 90.
set comp to 90.
set prev_maxthrust to 0.
lock steering to heading(comp,pit).
set safe_speed to 200.
set calc_throt to 1.
lock throttle to calc_throt.
stage.

until periapsis > 71_000 {
  // Steer and also Limit throttle if we're going too fast too low
  // in danger of getting hot:
  if altitude > 50000 {
    set pit to 0.
    set safe_speed to 2200.
  } else if altitude > 25000 {
    set pit to 30.
    set safe_speed to 1300.
  } else if altitude > 15000 {
    set pit to 35.
    set safe_speed to 1000.
  } else if altitude > 10000 {
    set pit to 45.
    set safe_speed to 700.
  } else if altitude > 7000 {
    set pit to 60.
    set safe_speed to 500.
  } else if altitude > 3000 {
    set pit to 70.
    set safe_speed to 300.
  } else if altitude > 1000 {
    set pit to 80.
    set safe_speed to 200.
  }
  if maxthrust = 0 or maxthrust < 0.9*prev_maxthrust {
    stage.
  }

  set calc_throt to (safe_speed/velocity:surface:mag)^3.

  set prev_maxthrust to maxthrust.

  display_block().
  wait 0.
}


function display_block {
  clearscreen.
  print "steering target: HEADING("+round(comp,1)+", "+round(pit,1)+")".
  print "Max Safe Speed: " + round(safe_speed).
}
