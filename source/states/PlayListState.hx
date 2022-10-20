package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import lime.utils.Assets;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import interfaz.*;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;

using StringTools;

class PlayListState extends MusicBeatState
{ 
 
    var curSelected:Int = 0;
    var songList:Array<String> = ['serva', 'scaled'];
    var bg:FlxSprite;
    var listBg:FlxSprite;
    var voices:FlxSound;
    var antName:String = '';


    var elpepe2014:Bool = false;
    var etesech:Bool = false;
    var songPlay:Bool = true;
    var songStop:Bool = false;
    var nameSong:String;

    var listSong:FlxTypedGroup<FlxSprite>;


    override public function create():Void
    {
        super.create();  

        bg = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('playList/bg')));
        add(bg);

        listBg = new FlxSprite(-500).loadGraphic(CoolUtil.getBitmap(Paths.image('playList/listBg')));
        add(listBg);

        FlxTween.tween(listBg, {x: listBg.x + 500}, 1, {ease:FlxEase.expoInOut, onComplete: function(flxTween:FlxTween)
            {
                elpepe2014 = true;
            }});

        listSong = new FlxTypedGroup<FlxSprite>();
		add(listSong);

        var tex = Paths.getSparrowAtlas('playList/playList');

        for (i in 0...songList.length)
		{
			var songLOL:FlxSprite = new FlxSprite(0, 0 + (i * 200));
			songLOL.frames = tex;
			songLOL.animation.addByPrefix('play', songList[i] + " play", 24);
			songLOL.animation.addByPrefix('stop', songList[i] + " stop", 24);
			songLOL.updateHitbox();
			songLOL.animation.play('play');
			songLOL.ID = i;
			listSong.add(songLOL);

        }

        changeItem(); 
    }

    override public function update(elapsed:Float):Void
    {
        if (controls.BACK)
	    {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(new ExtraState());
        }

        if (controls.DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(-1);
		}

        if (controls.UP_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(1);
		}

        if (controls.ACCEPT)
		{   
            //if (songPlay)
            //{          
            nameSong = songList[curSelected];  
                
            if (antName != nameSong)
            {   
                playSong();
                songStop = true;
            }
            else
            {
                if (songStop)
                    pauseSong();
                else
                    resumeSong();        
            }        
            
            //else
            //{
			    
            //}
            
            listSong.forEach(function(spr:FlxSprite)
            {
                spr.animation.play('play');
                
                if (spr.ID == curSelected)
                {
                    spr.animation.play('stop');
                    
                    if (songStop == false)
                        spr.animation.play('play');
                    else
                        spr.animation.play('stop');
                }
                spr.updateHitbox();
            });
        }


        super.update(elapsed);
    } 


    function changeItem(huh:Int = 0)
	{

		curSelected += huh;

		if (curSelected >= songList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = songList.length - 1;

		listSong.forEach(function(spr:FlxSprite)
        {
            spr.alpha = 0.5;
    
            if (spr.ID == curSelected)
            {
                spr.alpha = 1;
            }
            spr.updateHitbox();
        });
	}

    function playSong():Void
	{
        FlxG.sound.playMusic(Paths.full(nameSong), 1);
        songPlay = false; 
        antName = songList[curSelected];
    }
    function pauseSong():Void
	{
        FlxG.sound.music.pause();
        songStop = false; 
    }
    function resumeSong():Void
	{
        FlxG.sound.music.resume();
        songStop = true;
    }
}