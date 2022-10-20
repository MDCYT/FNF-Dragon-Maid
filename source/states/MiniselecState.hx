package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class MiniselecState extends MusicBeatState
{
	var curSelected:Int = 0;
    var minigames:Array<String> = ['dragon', 'yanken'];

    var miniGrp:FlxTypedGroup<FlxSprite>;
    var bg:FlxSprite;
    var intro:FlxSprite;
    var frame:FlxSprite;
    var selector:FlxSprite;
    var gold:FlxSprite;

    var finishIntro:Bool = false;
    var spam:Bool = true;

    public static var currentIntro:Bool = true;

    override function create()
    {
        super.create();

        if (TitleState.playSong)
        {
                FlxG.sound.playMusic(Paths.music('maidMenu'), 1);
                TitleState.playSong = false;
        }

        intro = new FlxSprite();
        intro.frames = Paths.getSparrowAtlas('miniSelec/intro');
        intro.animation.addByPrefix('in', 'intro', 24, false);
        intro.screenCenter();

        bg = new FlxSprite();
        bg.frames = Paths.getSparrowAtlas('miniSelec/bg');
        bg.animation.addByPrefix('bg', 'bg', 24, true);
        bg.animation.play('bg');
        bg.screenCenter();

        add(bg);

        miniGrp = new FlxTypedGroup<FlxSprite>();
        
        for (i in 0...minigames.length)
        {
            var mini:FlxSprite = new FlxSprite();
            mini.frames = Paths.getSparrowAtlas('miniSelec/selector');
            mini.animation.addByIndices('on', minigames[i] + ' on', [0], '', 24, false);
            mini.animation.addByIndices('off', minigames[i], [0], '', 24, false);
            mini.animation.addByPrefix('lock', 'lock', 24, false);
            mini.ID = i;

            mini.setGraphicSize(Std.int(mini.width * 6));
            mini.animation.play('off');
            mini.updateHitbox();

            if (i == 0) mini.setPosition(269, 248);
            else mini.setPosition(802, 248);

            miniGrp.add(mini);
        }

        frame = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('miniSelec/marco')));
        frame.screenCenter();

        selector = new FlxSprite(233, 213).loadGraphic(CoolUtil.getBitmap(Paths.image('miniSelec/da')));
        selector.setGraphicSize(Std.int(selector.width * 6));
        selector.updateHitbox();

        add(miniGrp);
        add(frame);
        add(selector);
        add(intro);

        if (currentIntro) theIntro();
        else 
        {
            intro.alpha = 0;
            finishIntro = true;
        }
        changeItem();

        if (FlxG.save.data.goldDragon){

            gold = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('miniSelec/goldDragon')));
            gold.setGraphicSize(Std.int(gold.width / 4.5));
            gold.updateHitbox();
            gold.antialiasing = false;
            gold.setPosition(15, 509);
            add(gold);
            
        }
        
    }

    function theIntro()
    {
        intro.animation.play('in');
        intro.animation.finishCallback = function(_){
            finishIntro = true;
        }
    }

    function changeItem(huh:Int = 0)
	{
		if (finishIntro)
		{
			curSelected += huh;
	
			if (curSelected >= miniGrp.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = miniGrp.length - 1;
		}

		miniGrp.forEach(function(spr:FlxSprite)
		{
            spr.animation.play('off');

            if (spr.ID == 0 && !FlxG.save.data.dragonHunt || spr.ID == 1 && !FlxG.save.data.yanken)
                spr.animation.play('lock');

			if (spr.ID == curSelected && finishIntro)
			{
                FlxTween.tween(selector, {x: spr.x - 35}, 0.2, {ease:FlxEase.expoInOut});

                if (spr.ID == 0 && !FlxG.save.data.dragonHunt || spr.ID == 1 && !FlxG.save.data.yanken)
                    spr.animation.play('lock');
			}

			spr.updateHitbox();
		});
	}

    override function update(elapsed:Float)
    {

        if (FlxG.mouse.pressed)
        {
            gold.setPosition(FlxG.mouse.x, FlxG.mouse.y);
            trace('x: ' + gold.x + ' y: ' + gold.y);
        }
        if (finishIntro)
        {
            if (FlxG.keys.justPressed.LEFT)
            {
                changeItem(-1);
            }
            if (FlxG.keys.justPressed.RIGHT)
            {
                changeItem(1);
            }
            if (FlxG.keys.justPressed.ENTER)
            {
                var selec:String = minigames[curSelected];

                switch (selec)
                {
                    case 'dragon':
                        if (FlxG.save.data.dragonHunt)
                        {
                            FlxG.sound.play(Paths.sound('maidShooting'));
                            miniGrp.members[0].animation.play('on');
                            currentIntro = false;
                            new FlxTimer().start(1, function(tmr:FlxTimer)
                            {
                                FlxG.switchState(new MinigameState());
                                MinigameState.miniState = true;   
                            });
                        }
                        else
                            FlxG.sound.play(Paths.sound('false'));

                    case 'yanken':
                        if (FlxG.save.data.yanken)
                        {
                            FlxG.sound.play(Paths.sound('pressEnter'));
                            currentIntro = false;
                            new FlxTimer().start(1, function(tmr:FlxTimer)
                            {
                            FlxG.switchState(new YankenState());
                            });
                        }
                        else
                            FlxG.sound.play(Paths.sound('false'));
                }
            }
            if (FlxG.keys.justPressed.ESCAPE)
            {  	
                FlxG.sound.play(Paths.sound('cancelMenu'));
                currentIntro = false;
                FlxG.switchState(new ExtraState());
            }
        }
        super.update(elapsed);
    }
}
