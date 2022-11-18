void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //float a = step(1.0, mod(iTime * 60.0, 2.0));
    float a = step(1.0, mod(fragCoord.y / 1.0, 2.0));
    
    vec4 b = vec4(a, 1.0 - a, 1.0 - a, a);
    
    vec4 noise = texture(iChannel1, vec2(iTime * 0.5, fragCoord.y / iChannelResolution[1].y));
    float n = pow(noise.x, 10.0);
    
	vec2 uv = vec2(fragCoord.x + n * 30.0, 1.0 - fragCoord.y) / iResolution.xy;
    vec4 tex = texture(bitmap, uv);
	fragColor = tex * b;
}