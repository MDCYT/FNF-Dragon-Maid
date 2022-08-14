package ui;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.FlxG;
import states.PlayState;

class PauseThing extends FlxSpriteGroup 
{
	public var grpMenuShit:FlxSpriteGroup;

	public var menuItems:Array<String> = ['resume', 'restart', 'exit'];
	public var curSelected:Int = 0;
	public var daAnimation:Int = PlayState.pauseAnimation;
	public var characterPause:Int = 0;
	
    public var circle:FlxSprite;
	public var artWork:FlxSprite;
	public var xAnim:Int;
	public var isSwitch:Bool = false;
    public var levelDifficulty:FlxText;
    public var levelInfo:FlxText;

    public var grpStars:FlxSpriteGroup;

	public var isClose:Bool = false;
    
    public function new(x:Float, y:Float, state:Int = 0)
    {
        super(x,y);

        switch(daAnimation)
		{
		    case 0:	
                xAnim = -700;
            case 1 | 2:
                xAnim = 0;
		}

        characterPause = state;

        circle = new FlxSprite(xAnim).loadGraphic(Paths.image('pauseState/circleLOL' + characterPause));
		add(circle);

		artWork = new FlxSprite(xAnim).loadGraphic(Paths.image('pauseState/artWork' + characterPause));
		add(artWork);

		var tex = Paths.getSparrowAtlas('pauseState/stars' + characterPause);

		grpStars = new FlxSpriteGroup();
		add(grpStars);

		for (i in 0...2)
		{
			var starringStar:FlxSprite = new FlxSprite();

			switch (i)
			{
				case 0:
					starringStar.x = -50;
					starringStar.y = -50;
					starringStar.angle = 0;
				case 1:
					starringStar.x = 320;
					starringStar.y = 505;
					starringStar.angle = 190;
			}

			starringStar.frames = tex;
			starringStar.animation.addByPrefix('idle', 'ASAAA', 24);
			starringStar.scale.set(0.6, 0.6);
			starringStar.updateHitbox();
			starringStar.animation.play('idle');

            if(daAnimation == 0) starringStar.alpha = 0;
            else starringStar.alpha = 1;

			grpStars.add(starringStar);
		}

        levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("Claphappy.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('Claphappy.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

        if(daAnimation == 0){
            levelDifficulty.alpha = 0;
            levelInfo.alpha = 0;
        }
        else{
            levelDifficulty.alpha = 1;
		    levelInfo.alpha = 1;
        }

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		grpMenuShit = new FlxSpriteGroup();
		add(grpMenuShit);

		var tex = Paths.getSparrowAtlas('pauseState/optionsPause' + characterPause);
		var daPos:Int;

		for (i in 0...menuItems.length)
		{
			switch (i)
			{
				case 1:
					daPos = 470;
				case 2:
					daPos = 450;
				default:
					daPos = 450;
			}

			var pauseItem:FlxSprite = new FlxSprite(daPos, -500);
			pauseItem.frames = tex;
			pauseItem.animation.addByPrefix('idle', menuItems[i] + " off", 24);
			pauseItem.animation.addByPrefix('selected', menuItems[i] + " on", 24);
			pauseItem.updateHitbox();
			pauseItem.animation.play('idle');
			pauseItem.ID = i;
			grpMenuShit.add(pauseItem);
			
			if (daAnimation == 0){
                FlxTween.tween(pauseItem,{y: 200 + (i * 150)}, 0.5 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
                { 
                    changeSelection();	
                }});
            }
            else{
                pauseItem.y = 200 + (i * 150);
                changeSelection();	
            }
		}

        if(daAnimation == 0)
            pauseIntro();
        else
            isSwitch = true;
    }

    function pauseIntro() {
        FlxTween.tween(circle, {x:circle.x + 700}, 0.7, {ease:FlxEase.expoInOut});	
        FlxTween.tween(artWork, {x:artWork.x + 700}, 0.7, {ease:FlxEase.expoInOut, onComplete: function(flxTween:FlxTween){
            FlxTween.tween(grpStars, {alpha: 1}, 0.3, {ease:FlxEase.quadInOut, onComplete: function(flxTween:FlxTween){
                isSwitch = true;
            }});
                    
        }});

        FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
    }

    function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		grpMenuShit.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
	
			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
			}
			spr.updateHitbox();
		});
	}

    override function update(elapsed:Float)
    {

		if (FlxG.keys.justPressed.UP && !isClose && isSwitch)
		{
            FlxG.sound.play(Paths.sound('scrollPause'));
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN && !isClose && isSwitch)
		{
            FlxG.sound.play(Paths.sound('scrollPause'));
			changeSelection(1);
		}

        super.update(elapsed);
    }
}