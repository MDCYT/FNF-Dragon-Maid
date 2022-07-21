
package;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import Shaders;
import flixel.FlxCamera;

class ShaderManager
{
    //Manager de shaders por aparte porque usar modcharts es de maricas
    
    public static var camShaders = [];

    public static function addCamEffect(effect:ShaderEffect, daCamera:FlxCamera)
        {
            camShaders.push(effect); 
            var newCamEffects:Array<BitmapFilter> = []; 
            for (i in camShaders)
            {
                newCamEffects.push(new ShaderFilter(i.shader));
            }
    
            daCamera.setFilters(newCamEffects);
            
        }
}