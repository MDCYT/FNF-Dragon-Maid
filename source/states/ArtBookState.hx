package states;

#if desktop
import Discord.DiscordClient;
#end
import openfl.display.Tile;
import lime.graphics.Image;
import flixel.FlxG;
import ui.*;
import flixel.FlxSprite;
import flixel.FlxState;
import lime.utils.Assets;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxBasic;
import flixel.FlxObject;
import openfl.Lib;
  
using StringTools;

class ArtBookState extends MusicBeatState
{
    var trans:MaidTransition;
    var artList:Array<String> = [
        'Tohru sketchs', 
        'Elma sketchs', 
        'Angry Tohru first desing', 
        'Emo Tohru', 
        'Thoru sus OMG',
        'Other angry Tohru desing',
        'Wall sketch',
        'FREE PALESTINE',
        'OMG',
        'Cherlok is dumb',
        'The Team CP',
        'Kobayashi Sketch',
        'Keki needs urgent help, it scares me',
        'BF Maid first desing icon',
        'Another angry Tohru desing',
        'lucoa sketch',
        'Perdi al bebe Aron :,v'

    ]; //Lista de Artes
    var artgrp:FlxTypedGroup<ArtThing>;
    var circGrp:FlxTypedGroup<FlxSprite>;

    var bg:FlxSprite;
    var curSelected:Int = 0;
    var title:FlxText;
    var image:ArtThing;
    var titleArt:FlxText;

    override public function create():Void
    {  
        super.create();
        
        Lib.current.stage.window.title = TitleState.title + ' - Art Menu';

        #if desktop
		DiscordClient.changePresence("Artbook", null);
		#end

        trans = new MaidTransition(0, 0);
        trans.screenCenter();
    
        TitleState.playSong = true;

        FlxG.sound.playMusic(Paths.music('sleep')); //la cancion que hice para el menu, me dormi escuchandola el otro dia XD 
        
        transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

        titleArt = new FlxText(0, 615, FlxG.width, "", 32);
		titleArt.setFormat("Claphappy.ttf", 15, FlxColor.WHITE, CENTER);
        titleArt.setBorderStyle(OUTLINE, 0xFF6b1700, 2);
        titleArt.screenCenter(X);

        bg = new FlxSprite(0,0);
		bg.frames = Paths.getSparrowAtlas('artMenu/bg');
        bg.animation.addByPrefix('bg', 'bg', 24, true);
        bg.animation.play('bg');
        bg.antialiasing = true;
		bg.screenCenter();
        add(bg);

        var shape:FlxSprite = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('artMenu/shapes')));
        shape.antialiasing = true;
        shape.screenCenter();

        var hud:FlxSprite = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('artMenu/Hud')));
        hud.antialiasing = true;
        hud.screenCenter();

        add(shape);

        FlxTween.tween(shape, {alpha: 0.6}, 4, {type: PINGPONG});

        artgrp = new FlxTypedGroup<ArtThing>();
		add(artgrp);

        circGrp = new FlxTypedGroup<FlxSprite>();

        for (i in 0...artList.length)
		{
			image = new ArtThing(0, 40, i);
            image.targetY = i;
            image.alpha = 0;
            image.antialiasing = true;
            image.screenCenter(X);
			artgrp.add(image);

            var circ:FlxSprite = new FlxSprite();
            circ.frames = Paths.getSparrowAtlas('artMenu/circ');
            circ.animation.addByPrefix('on', 'circOn', 24, false);
            circ.animation.addByPrefix('off', 'circOff', 24, false);
            circ.animation.play('off');
            circ.antialiasing = true;
            circ.setGraphicSize(Std.int(circ.height / 7));
            circ.updateHitbox();
            circ.ID = i;
            circ.setPosition(308 + (i* 40), 533);

            circGrp.add(circ);
        }

        add(hud);
        add(circGrp);
        add(titleArt);
        
        changeSelection();

        FlxG.mouse.visible = true;

        add(trans);
        trans.transOut();
    }

    function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('artbookstep'), 0.4); //el sonido de pasar hoja XD

		curSelected += change;

		if (curSelected >= artList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = artList.length - 1;

        var bullShit:Int = 0;

        var omuraisu:String = artList[curSelected];

        for (item in artgrp.members)
		{            
			item.targetY = bullShit - curSelected;

            switch (omuraisu)
            {
                case 'Tohru sketchs'|'Elma sketchs':
                    item.scale.set(0.1, 0.1);
                case 'Keki needs urgent help, it scares me':
                    item.scale.set(0.3, 0.3);
                case 'FREE PALESTINE':
                    item.scale.set(0.8, 0.8);
                case 'The Team CP':
                    item.scale.set(0.5, 0.5);
                case 'Thoru sus OMG' | 'Perdi al bebe Aron :,v':
                    item.scale.set(0.4, 0.4);
                default:
                    item.scale.set(1, 1);
            }

            item.screenCenter(Y);
            item.y = 50;
			
            if (item.targetY == Std.int(0))
				item.alpha = 1;
            else
                item.alpha = 0;

            item.antialiasing = true;
			bullShit++;
		}

        circGrp.forEach(function(spr:FlxSprite)
        {
            spr.animation.play('off');
            if (spr.ID == curSelected){
                spr.animation.play('on');
            }
        });

        titleArt.text = artList[curSelected].toUpperCase();//el titulo de cada arte
    
    }

    override public function update(elapsed:Float):Void
    {   
        if (controls.BACK)
	    {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            trans.transIn('extra');
        }

        if (controls.LEFT_P)
        {   
            changeSelection(-1);
        }
	
			
        if (controls.RIGHT_P)
        {
            changeSelection(1);
        }
	

        super.update(elapsed);
    }

}