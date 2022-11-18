void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy, m = iMouse.xy/R; 
	U/= R;
    float d = (length(m)<.02) ? .015 : m.x/10.;
  //float d = (length(m)<.02) ? .05-.05*cos(iDate.w) : m.x/10.;
 
	O = vec4( texture(bitmap,U-d).x,
              texture(bitmap,U  ).x,
              texture(bitmap,U+d).x,
              1);
}