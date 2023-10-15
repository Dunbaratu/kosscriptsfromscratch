// orbit script to go with firstorb ship design.
// This is hardcoded to only work with that specific design.

core:doevent("Open Terminal").
print "Type Any Key to Start Launch.".
set ch to terminal:input:getchar().
print "Here We Go!".

clearscreen.

set end_altitude to 71_000.
set pit to 90.
set comp to 90.
set prev_maxthrust to 0.
lock steering to heading(comp,pit).
set safe_speed to 200.
set calc_throt to 1.
lock throttle to calc_throt.
stage.

set step to 1.
set step_name to LIST(
  "prelaunch", "ascending", "coasting", "circularizing" ).


set done to false.
until done {
  // Steer and also Limit throttle if we're going too fast too low
  // in danger of getting hot:
  if altitude > 50_000 {
    set pit to 0.
    set safe_speed to 2400.
  } else if altitude > 25_000 {
    set pit to 30.
    set safe_speed to 1300.
  } else if altitude > 15_000 {
    set pit to 35.
    set safe_speed to 1000.
  } else if altitude > 10_000 {
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

  if        step = 1 and apoapsis > end_altitude {
    set step to 2.
  } else if step = 2 and eta:apoapsis < 10 {
    set step to 3.
  }

  if step = 1 {
    // max throttle unless going too fast for altitude:
    set calc_throt to (safe_speed/velocity:surface:mag)^3.
  } else if step = 2 {
    // mildly throttle if the apoapsis is degrading from drag.
    set calc_throt to (end_altitude - apoapsis) / 200.
  } else if step = 3 {
    // throttle up a lot at first, then slow it down near the end.
    // ------
    // First, get trueanomly as a value -180 to 180, rather than 0 to 360:
    if obt:trueanomaly > 180 {
      set signed_trueanomaly to obt:trueanomaly - 360.
    } else {
      set signed_trueanomaly to obt:trueanomaly.
    }
    // Second - throttle more the further from Periapsis we are,
    // slowing down as periapsis swings to the other side of the orbit:
    set calc_throt to ((abs(signed_trueanomaly)-90)/30).

    // See if done because Pe has swung around mostly to the other side:
    if signed_trueanomaly > -30 and signed_trueanomaly < 30 {
      set done to true.
    }
  }

  set prev_maxthrust to maxthrust.

  display_block().
  wait 0.
}
print "DONE.".

function display_block {
  clearscreen.
  print "steering target: HEADING("+round(comp,1)+", "+round(pit,1)+")".
  print "Max Safe Speed: " + round(safe_speed).
  print "Step: " + step_name[step].
  if step = 2 {
    print "ETA: Apoapsis: " + round(eta:apoapsis).
  }
  if step = 3 {
    print "signed_trueanomaly: " + round(signed_trueanomaly).
  }
}
