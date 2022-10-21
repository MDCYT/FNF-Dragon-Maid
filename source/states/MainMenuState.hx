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
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
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
import openfl.display.BlendMode;


class MainMenuState extends MusicBeatState
{
	var trans:MaidTransition;
	var cartel:Warning;
	var achievement:MaidAchievement;
	var curSelected:Int = 0;
	var change:Int = 2;
	public var currentOptions:Options;

	var menuItems:FlxTypedGroup<MainThing>;
	public static var profile:Profile;

	#if !switch
	var optionShit:Array<String> = ['Story', 'Freeplay', 'Extra', 'Options'];
	#else
	var optionShit:Array<String> = ['Story', 'Freeplay'];
	#end

	var bg:FlxBackdrop;
	var eventBlack:FlxSprite;

	public static var animAchi:Bool = false;
	public static var daAchi:Int = 0;
	public static var firstStart:Bool = true;

	var hora:String;
	var extra:FlxSprite;
	var selectedSomethin:Bool = true;
	var rectangle:FlxSprite;
	var time:Int = 0;
	var warning:FlxSprite;

	var inWarn:Bool = false;

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

		PlayState.pauseAnimation = 0;

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

		bg = new FlxBackdrop(CoolUtil.getBitmap(Paths.image('mainMenu/menuBg')), 10, 0, true, false);
		bg.velocity.set(-150, 0);
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
			menuItem.antialiasing = true;

			trace(menuItem.color);

			//menuItem.blend = BlendMode.SUBTRACT;

			menuItems.add(menuItem);
			if (firstStart){
				FlxTween.tween(menuItem,{y: 77.55}, 1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						FlxTween.tween(menuItem, {y: menuItem.y + 10}, 5, {ease: FlxEase.expoInOut, type: PINGPONG});
						if (i == 0) changeItem();
						if (i == optionShit.length - 1){
							selectedSomethin = false;
						}
					}});
			}
		}

		rectangle =  new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('mainMenu/rectangle')));
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

		profile = new Profile(0, 500, FlxG.save.data.userTheme);
		profile.alpha = 0;
		profile.screenCenter();
		profile.antialiasing = true;
		add(profile);
		
		profile.active = false;
	
		warning = new FlxSprite(1030, 660);
		warning.frames = Paths.getSparrowAtlas('profile/warning');
		warning.animation.addByPrefix('on', 'GOOD');
		warning.animation.addByPrefix('off', 'ERROR');
    	warning.animation.addByPrefix('press', 'SAVE');
		warning.updateHitbox();
		warning.antialiasing = true;
		warning.alpha = 0;

		trace(warning.frames);
		add(warning);

		cartel = new Warning(0, 0, false, true);
		cartel.antialiasing = true;
		add(cartel);

		changeItem();

		trace(profile.x + ' ' + profile.y);

		FlxG.mouse.visible = true;

		add(trans);
		trans.transOut();
	}

	function createWarn(dialog:Int = 0, type:String = 'warning', ?gfAnim:String = 'smile', ?typeBtn:Int) {
        if(!inWarn) cartel.setWarn(dialog, type, gfAnim, typeBtn);
        cartel.popUp();
        inWarn = true;
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

	function updateUser(){

		var uuid = FlxG.save.data.uuid;

		var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/username/" + uuid);

        var data = haxe.Json.stringify({
            username: profile.user
        }, "\t");

        http.addHeader('Content-Type', 'application/json');
        http.setPostData(data);

        http.onStatus = function(status) {
            if(status == 200)
            {
				checkChanges(true);
                trace("Success!");
            }
            else
            {
				checkChanges(false);
				createWarn(2, 'warning', null, 3);
                trace("Error!");
            }
        }

		http.onError = function(status) {
			createWarn(2, 'warning', null, 3);
			trace("Error!");
		};

        http.request(true);

	}

	function checkChanges(ol:Bool){
		if (ol)
			warning.animation.play('on');
		else
			warning.animation.play('off');
		warning.alpha = 1;
		FlxTween.tween(warning, {alpha: 0}, 3);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.P && FlxG.keys.pressed.CONTROL){
			if (FlxG.save.data.userTheme == 1)
				FlxG.save.data.userTheme = 0
			else
				FlxG.save.data.userTheme = 1;
		}
		if (!inWarn){
			if (profile.user != FlxG.save.data.user && profile.alpha == 1){
				profile.inEdit = true;
				warning.alpha = 0.7;
				warning.animation.play('press');
			}
	
			if(FlxG.keys.justPressed.ENTER && profile.inEdit && profile.alpha == 1){
				updateUser();
				profile.inEdit = false;
				profile.nameText.hasFocus = false;
				FlxG.save.data.user = profile.user;
			}
	
			if (FlxG.keys.justPressed.Q){
				loadSong();
			}
		}
		else{
			if (FlxG.keys.justPressed.ENTER) {
				FlxG.sound.play(Paths.sound('ann'));
                cartel.popOut();
				profile.userOpen(false);
				FlxTween.tween(eventBlack, {alpha: 0}, 0.3, {onComplete: function (_) {
					inWarn = false;
				}});
			}
		}

		if(FlxG.keys.justPressed.ONE){FlxG.switchState(new NESState());}

		if(FlxG.keys.justPressed.TWO){FlxG.switchState(new ShopState());}

		if (FlxG.keys.justPressed.L){
		}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (profile.alpha == 1 && !profile.inEdit && !profile.nameText.hasFocus){
				FlxTween.tween(eventBlack, {alpha: 0}, 0.3);
				profile.userOpen(false);
			}
			if (profile.alpha == 0){
				FlxTween.tween(eventBlack, {alpha: 0.5}, 0.3);
				profile.userOpen(true);
				profile.discordChange(profile.colors[profile.numColor]);
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

		if (!selectedSomethin && !inWarn|| !inWarn)
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
		if(force){
			curSelected=huh;
		}else{
			curSelected += huh;
	
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
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

			if (spr.ID == curSelected)
			{
				spr.animation.play('on');
				spr.alpha = 1;
			}

			spr.updateHitbox();
		});

	}
}
