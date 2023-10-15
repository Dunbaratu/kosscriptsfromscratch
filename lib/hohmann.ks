// Calculate and return the parameters of a hohmann transfer.

@lazyglobal off.

///////////////
// Warning: Hohmann transfer assumes source and target orbits are circular.
//          If they are not, then it can fail to give a good transfer.
///////////////

// Returns 2 things in a LEX:
//   ["ETA"] = seconds from now until the burn would have to happen.
//   ["dV"] = scalar prograde delta V (if < 0 it means burn retrograde).

function hohmann {
  parameter src, tgt, debug is false. //should both be an "orbitable".

  // First Get the deltaV amount, then figure out WHEN to do it:

  // dV amount:
  local mu is src:body:mu.
  local r1 is src:obt:semimajoraxis.
  local r2 is tgt:obt:semimajoraxis.

  local dV is 0.
  set dV to sqrt(mu/r1) * ( sqrt(2*r2/(r1+r2)) - 1 ).

  if debug print "hohman debug: dV = " + dv.

  // Now , WHEN to do it:
  
  // Period of transfer orbit is how long transfer takes:
  local SMAtrans is (r1+r2)/2.

  if debug print "hohman Transsfer patch SMA = " + SMATrans.

  local Ttrans is 2*constant:pi*sqrt(SMAtrans^3/mu).

  if debug print "hohman Transfer period = " + Ttrans.

  // Degrees target will travel in 1/2 transfer orbit:
  local traveltrans is ((0.5*Ttrans)/tgt:obt:period)*360.

  if debug print "hohman degreees target travels = " + traveltrans.
  
  // phase angle vs target at time of burn should be:
  local phase is 180 - traveltrans.

  if debug print "hohman desired phase angle = " + phase.

  // degrees per second that source vs target angle changes:
  local deg_rate1 is 360 / src:obt:period.
  local deg_rate2 is 360 / tgt:obt:period.

  local catchup_rate is abs(deg_rate1 - deg_rate2).

  if debug print "hohman phase change (deg/sec) = " + catchup_rate.

  // current degrees between me and target:
  local cur_phase is vang(
    (src:position-src:body:position):normalized,
    (tgt:position-src:body:position):normalized).

  // Check if target is behind source:
  if vdot(src:velocity:orbit:normalized, (tgt:position-src:position):normalized) < 0 {
    set cur_phase to cur_phase + 180.
  }

  if debug print "hohman current phase angle = " + cur_phase.

  // Time to wait is how long it will take to consume that much angle:
  local phase_ahead is (phase - cur_phase).
  if phase_ahead < 0 set phase_ahead to phase_ahead+360.
  local wait_for is (phase_ahead) / catchup_rate.

  if debug print "hohman ETA to burn = " + wait_for.

  return LEX("ETA",wait_for,"dV",dv).
}
