package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxCollision;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import ui.*;
import flixel.util.FlxTimer;
import flash.system.System;
using StringTools;
import flixel.FlxCamera;
import openfl.Lib;
import openfl.Assets;
import Shaders;
import flash.display.BitmapData;
import flash.display.Bitmap;

class WindowsManager{
  
    //Esto queda pendiente, basicamente hacer que cada ventana tenga un ID unico desde el manager :P
    public static var newin:openfl.display.Window;
   //Vete a la vergaaaaaaaaaaaaaaaaaaaaaaaaaa
    public static function createWindow(title:String, width:Int, height:Int, border:Bool, spritePath:String, ?centerTheThing:Bool = true){
         newin = Lib.application.createWindow({
            width: width,
            height: height,
            title: title,
            borderless: border 
        });
        var zoom:Float = -1;
        var dastageWidth:Int = newin.stage.stageWidth;
        var dastageHeight:Int = newin.stage.stageHeight;

        var bitmapData:BitmapData;
         bitmapData = Assets.getBitmapData(spritePath);

         var bitmap = new Bitmap (bitmapData);

         //¿Por que mierda no querria centrar el coso lol?
         if(centerTheThing)
            {
                var ratioX:Float = dastageWidth / width;
                var ratioY:Float = dastageHeight / height;
                zoom = Math.min(ratioX, ratioY);
                bitmap.width = Math.ceil(dastageWidth / zoom);
                bitmap.height = Math.ceil(dastageHeight / zoom);
            }
           

         newin.stage.addChild(bitmap);
    }
    /*
    public function centerSpr(spr:Bitmap, width, height)
        {
           
        }
        */
}