parameter src is 0, tgt is 0.

print "testing hohmann lib.".

if src:istype("scalar") or tgt:istype("scalar") {
  print "Requires 2 args, both are orbitables.".
} else {

  runoncepath("lib/hohmann").

  local result is hohmann(src,tgt,true).

  print "ETA to burn would be " + timespan(result["ETA"]):full.
  print "PRO to burn would be " + round(result["dV"],1) + " m/s.".
}
