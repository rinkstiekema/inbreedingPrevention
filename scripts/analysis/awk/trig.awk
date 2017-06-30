function asin(x) { return atan2(x, sqrt(1-x*x)) }
function acos(x) { return atan2(sqrt(1-x*x), x) }
function atan(x) { return atan2(x,1) }
function radToDeg(x) { return (x * 180) / 3.14159 }
{ 
  print $1, $2, radToDeg(asin($2));
}