package states;

#if desktop
import Discord.DiscordClient;
#end
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
import ShaderManager;
import Shaders;
import flash.display.BitmapData;
import flash.display.Bitmap;
import WindowsManager;
class BadDragonState extends MusicBeatState
{
    public static var bg:FlxSprite;
    var dragon:FlxSprite;
    var bf:BadBoyfriend;
    var fire:FlxSprite;
    var screamer:FlxSprite;

    var nothing:FlxSound;
    var jump:FlxSound;

    var timer:Float = 0; //no puedo creer que estoy siguiendo un tutorial de haxe
    var jumping:Bool = false;

    var fireMov:FlxTween;
    var vel:Float = 4;
    var defCam:FlxCamera;
    var tumadre2:VCRDistortionEffect;
    var bitmapData:BitmapData;
    var zoom:Float = -1;
    var daWindows:openfl.display.Window;
    
    override function create()
    {
        super.create();

        #if desktop
		DiscordClient.changePresence("Маған көмектесші", null);
		#end

        tumadre2 = new VCRDistortionEffect();
        //Para despues, hacer que esta mierda tenga menos metodos dios que horrible se ve tener que hacer tantos metodos para una jodida viñeta del shader
        tumadre2.setVignette(true);
        tumadre2.setVignetteMoving(false);
        tumadre2.setGlitchModifier(0);
        tumadre2.setDistortion(true); 
       
        tumadre2.setNoise(true);

        defCam = new FlxCamera();
        FlxG.cameras.reset(defCam);

        ShaderManager.addCamEffect(tumadre2, defCam);



        FlxG.sound.playMusic(Paths.music('bad'), 1);

        bg = new FlxSprite(0, 412).makeGraphic(FlxG.width, 300, FlxColor.BLACK);
        bg.immovable = true;
        bg.screenCenter(X);
        add(bg);

        fire = new FlxSprite().loadGraphic(Paths.image('bad/fire'));
        fire.setGraphicSize(Std.int(fire.width / 3.4));
        fire.antialiasing = false;
        fire.updateHitbox();
        add(fire);

        dragon = new FlxSprite(10, bg.y - 160).loadGraphic(Paths.image('bad/bad'));
        dragon.setGraphicSize(Std.int(dragon.width / 3));
        dragon.updateHitbox();
        dragon.antialiasing = false;
        dragon.flipX = true;
        add(dragon);

        fire.setPosition(dragon.x + 30, dragon.y + Std.int(dragon.y / 2));

        bf = new BadBoyfriend(720, bg.y - bg.width);
        add(bf);

        screamer = new FlxSprite().loadGraphic(Paths.image('bad/scream'));
        screamer.screenCenter();
        screamer.alpha= 0;
        add(screamer);

        defCam.visible = false;

        new FlxTimer().start(2, function(tmr:FlxTimer)
        {
            defCam.visible = true;
            shoot(vel);
        });
    }

    function shoot(vel:Float = 0)
    {
        if (!fire.exists) fire.revive();
        fireMov = FlxTween.tween(fire, {x: 1280 + fire.width}, vel, {onComplete: function(twn:FlxTween){
            fire.kill();
            fire.setPosition(dragon.x + 30, dragon.y + Std.int(dragon.y / 2));
            vel -= 0.1;
            dragon.x += 20;
            shoot(vel);
        }});
    }
   var startDrawing:Bool = false;

    function die(type:String)
    {
        bf.animation.pause();
        fireMov.cancel();
        fire.kill();
        FlxG.sound.pause();
        
        if (type == 'bad')
        {
            screamer.alpha = 1;
            Lib.current.stage.window.borderless = true;
            new FlxTimer().start(3, function(tmr:FlxTimer)
            {
            
                WindowsManager.createWindow('dragon.bat', 700, 500, false, Paths.image('bad/scream'));
              
            });
        }
        else if (type == 'good')
        {
            trace(FlxG.save.data.bad);
            if (!FlxG.save.data.bad){
                MainMenuState.daAchi = 5;
				MainMenuState.animAchi = true;
                FlxG.save.data.bad = true;
            }
            FlxG.switchState(new MainMenuState());
        }
    }
    
    function sound(sounde:String)
    {
        FlxG.sound.play(Paths.sound(sounde));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        tumadre2.update(elapsed);
      
        //FlxG.fullscreen = true;

        if (vel <= 0.5)
            vel = 0.5;

        fire.updateHitbox();
        bf.updateHitbox();
        dragon.updateHitbox();

        //Esta funcion sigue corriendo a pesar de haber muerto, hay una fuga de memoria, gracias a eso puedo multiplicar las ventanas sin parar :P
        if(fire.overlaps(bf))die('bad');
        else if (dragon.overlaps(bf)) die('good');

        if (dragon.overlaps(bf)){
            FlxG.save.data.badDragon = true;
            trace(FlxG.save.data.badDragon);
        }

        FlxG.collide(bf, bg);

        var putoJump:Bool = FlxG.keys.justPressed.SPACE;

		if (jumping && !putoJump)
        {
			jumping = false;
        }

		if (bf.isTouching(DOWN) && !jumping)
        {
            bf.animation.play('walk');
		    timer = 0;
        }

		if (timer >= 0 && putoJump)
		{
			jumping = true;
			timer += elapsed;
		}
		else
			timer = -1;

		if (timer > 0 && timer < 0.25)
        {
			bf.velocity.y = -700;
        }

        if (jumping){
            bf.animation.play('jump');
            sound('jump');
        }
    }
}