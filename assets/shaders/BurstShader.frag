// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
		
float hash(in float n) { return fract(sin(n)*43758.5453123); }
		
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec4 c0 = texture(bitmap,fragCoord.xy/iResolution.xy);
			
			
	float t = pow((((1. + sin(iTime * 10.) * .5)
	*  .8 + sin(iTime * cos(fragCoord.y) * 41415.92653) * .0125)
	* 1.5 + sin(iTime * 7.) * .5), 5.);
			
    vec4 c1 = texture(bitmap, fragCoord.xy/(iResolution.xy+vec2(t * .2,.0)));
	vec4 c2 = texture(bitmap, fragCoord.xy/(iResolution.xy+vec2(t * .5,.0)));
	vec4 c3 = texture(bitmap, fragCoord.xy/(iResolution.xy+vec2(t * .9,.0)));
			
	float noise = hash((hash(fragCoord.x) + fragCoord.y) * iTime) * .055;
			
	fragColor = vec4(vec3(c3.r, c2.g, c1.b) + noise, 1.);
}