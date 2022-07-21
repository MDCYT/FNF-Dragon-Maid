package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import io.newgrounds.NG;
import flixel.system.FlxSound;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
import openfl.Lib;
import flixel.input.mouse.FlxMouseEventManager;
import flash.system.System;
import ui.*;
import sys.io.File;


class MainMenuState extends MusicBeatState
{
	var trans:MaidTransition;
	var achievement:MaidAchievement;
	var curSelected:Int = 0;
	public var currentOptions:Options;

	var menuItems:FlxTypedGroup<MainThing>;
	var profile:Profile;

	#if !switch
	var optionShit:Array<String> = ['Story', 'Freeplay', 'Extra', 'Options'];
	#else
	var optionShit:Array<String> = ['Story', 'Freeplay'];
	#end

	var bg:FlxSprite;
	var eventBlack:FlxSprite;

	public static var animAchi:Bool = false;
	public static var daAchi:Int = 0;
	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;

	var hora:String;
	var extra:FlxSprite;
	var selectedSomethin:Bool = true;
	var rectangle:FlxSprite;
	var time:Int = 0;

	function accept(){

		selectedSomethin = true;
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			time ++;

			FlxTween.tween(spr,{y: spr.y - 300, alpha: 0}, 1 + (time * 0.25), {ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
			{ 
					var daChoice:String = optionShit[curSelected];
	
					switch (daChoice)
					{
						case 'Story':
							trans.transIn('story');
						case 'Freeplay':
							trans.transIn('free');
						case 'Extra':
							trans.transIn('extra');
						case 'Options':
							trans.transIn('options');
					}
				
			}});
		});
	}

	override function create()
	{
		super.create();

		PlayState.lifes = 3;

		if (PlayState.bad)
			PlayState.bad = false;

		if (Lib.current.stage.window.borderless){
			Lib.current.stage.window.borderless = false;
		}

		Lib.current.stage.window.title = TitleState.title + ' - Main Menu';

		trans = new MaidTransition(0, 0);
		trans.screenCenter();

		#if desktop
		DiscordClient.changePresence("Main Menu", null);
		#end

		currentOptions = OptionUtils.options;

		if (TitleState.playSong)
		{
			loadSong();
		}

		if(FlxG.sound.volume == 0){
			FlxG.sound.volume = 1;
		}
		
		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('mainMenu/menuBg');
		bg.animation.addByPrefix('bg', 'bg', 24, true);
		bg.animation.play('bg');
		bg.flipX = true;
		bg.updateHitbox();
		bg.screenCenter();	
		add(bg);

		extra = new FlxSprite();
		extra.frames = Paths.getSparrowAtlas('mainMenu/shapes');
		extra.animation.addByPrefix('shape', 'shape', 24, true);
		extra.animation.play('shape');
		extra.screenCenter();
		extra.antialiasing = true;
		add(extra);

		FlxTween.tween(extra, {y: extra.y + 10}, 2.5, {ease: FlxEase.circInOut, type: PINGPONG});

		var pos:Array<Int> = [101, 305, 653, 913];

		menuItems = new FlxTypedGroup<MainThing>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:MainThing = new MainThing(0, 700, optionShit[i]);
			menuItem.x = pos[i];
			menuItem.ID = i;

			menuItems.add(menuItem);
			if (firstStart){
				FlxTween.tween(menuItem,{y: 77.55}, 1.5 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						FlxTween.tween(menuItem, {y: menuItem.y + 10}, 5, {ease: FlxEase.expoInOut, type: PINGPONG});
						changeItem();
						finishedFunnyMove = true; 
						selectedSomethin = false;
					}});
			}
		}

		rectangle =  new FlxSprite().loadGraphic(Paths.image('mainMenu/rectangle'));
		rectangle.screenCenter();
		add(rectangle);

		eventBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		eventBlack.alpha = 0;
		add(eventBlack);

		if (animAchi)
		{
			achievement = new MaidAchievement(1280, 527, daAchi);
			add(achievement);

			trace('lol');

			eventAchi();
		}

		var versionShit:FlxText = new FlxText(5, FlxG.height - 1, 0, "v" + Application.current.meta.get('version') + " - Andromeda Engine PR1", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		profile = new Profile(0, 500,  0);
		profile.alpha = 0;
		profile.screenCenter();
		add(profile);

		profile.active = false;

		changeItem();

		trace(profile.x + ' ' + profile.y);

		FlxG.mouse.visible = true;

		add(trans);
		trans.transOut();
	}

	function loadSong() {
		FlxG.sound.pause();
		FlxG.sound.playMusic(Paths.musicRandom('maidTheme', 1, 4), 1, true);
		TitleState.playSong = false;
	}

	function eventAchi(){
		FlxG.sound.play(Paths.sound('achievement'));
			
		FlxTween.tween(achievement, {x: achievement.x - 540}, 1, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween){
			animAchi = false;
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxTween.tween(achievement, {x: achievement.x + 542}, 0.7, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween){
					achievement.kill();
				}});
			});
		}});
	}
	var da:Int;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.Q){
			loadSong();
		}

		if (FlxG.keys.justPressed.L){
		}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (profile.alpha == 1){
				FlxTween.tween(eventBlack, {alpha: 0}, 0.3);
				profile.userOpen(false);
			}
			if (profile.alpha == 0){
				FlxTween.tween(eventBlack, {alpha: 0.5}, 0.3);
				profile.userOpen(true);
			}
		} 

		if (FlxG.keys.justPressed.T && FlxG.keys.pressed.CONTROL)
		{
			//userOpen(false);
			trace(Date.now());
			hora = DateTools.format(Date.now(), "%H");
			trace(hora);

			if(hora == '03')
				FlxG.switchState(new BadDragonState());
			else
				FlxG.switchState(new BadDragonState());
				//Ooops
			//FlxG.switchState(new MinigameState());
			//FlxG.switchState(new BadDragonState());
		} 

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		//FlxG.mouse.visible=true;

		if (!selectedSomethin)
		{
			if (controls.LEFT_P && !profile.isOpen)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.RIGHT_P && !profile.isOpen)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT && !profile.isOpen)
			{
				FlxG.sound.play(Paths.sound('pressEnter'));
				accept();
			}
		}

		super.update(elapsed);
	}

	private inline function sortLow(order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int
	{
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.ID, Obj2.ID);
	}

	private inline function sortHigh(order:Int, Obj1:FlxSprite, Obj2:FlxSprite):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.ID, Obj2.ID);
	}

	function changeItem(huh:Int = 0,force:Bool=false)
	{
		if (finishedFunnyMove)
		{
			if(force){
				curSelected=huh;
			}else{
				curSelected += huh;
	
				if (curSelected >= menuItems.length)
					curSelected = 0;
				if (curSelected < 0)
					curSelected = menuItems.length - 1;
			}
		}

		switch (curSelected){
			case 0:
				menuItems.sort(sortLow);
			default:
				menuItems.sort(sortHigh);
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('off');
			spr.alpha = 0.7;

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('on');
				spr.alpha = 1;
			}

			spr.updateHitbox();
		});

	}
}
