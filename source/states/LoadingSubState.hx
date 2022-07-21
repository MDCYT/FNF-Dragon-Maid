package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import lime.app.Application;
import ui.*;

class LoadingSubState extends MusicBeatState
{
	var txtLoad:Array<Dynamic> = [
	['(', 'O', 'w', 'O', ')'], 
	['(', 'U', 'w', 'U', ')'], 
	['(', 'T', 'n', 'T', ')'], 
	['(', 'O', '<', 'O', ')'],
	['(', '°', '<', '°', ')' ]
	];

	var helpers:Array<String> = ['Este es un consjeo de prueba', 
	'Las flechas rojas te matan', 
	'Hola soy homero chino'
	];

	var lyric:Array<String> = [];

	var randomTxt:Int;

	var grpLyric:FlxTypedGroup<FlxText>;
	var helperTxt:FlxText;
	var yellowScreen:FlxSprite;

	override function create()
	{
		super.create();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		yellowScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFfbf80d);
		add(yellowScreen);

		grpLyric = new FlxTypedGroup<FlxText>();
		add(grpLyric);

		for (i in 0...5)
		{
			var lyrics:FlxText = new FlxText(0, 0, FlxG.width);
			lyrics.setFormat(Paths.font('loadFont.ttf'), 165, FlxColor.BLACK, CENTER);
			lyrics.text = '.';
			lyrics.setPosition(-300 + (i * 150), 250);
			grpLyric.add(lyrics);
		}

		randomTxt = Std.random(txtLoad.length);
		lyric = txtLoad[randomTxt];

		helperTxt = new FlxText(0, 800, FlxG.width);
		helperTxt.setFormat(Paths.font('loadFont.ttf'), 32, FlxColor.BLACK, CENTER);
		helperTxt.text = helpers[Std.random(helpers.length)];
		helperTxt.screenCenter(X);
		add(helperTxt);

		changeLyric();
	}

	var scroll:Int = 0;

	function changeLyric(){

		grpLyric.members[scroll].text = lyric[scroll];

		scroll += 1;
		trace(scroll);
		trace(lyric.length);

		FlxG.sound.play(Paths.sound('scrollMenu'));

		new FlxTimer().start(0.6, function(tmr:FlxTimer)
		{
			switch(scroll){
				
				case 3:
					FlxTween.tween(helperTxt, {y: helperTxt.y - 200}, 0.5, {ease: FlxEase.bounceInOut});
					changeLyric();
				case 5:
					new FlxTimer().start(0.6, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState());
					});
				default:
					changeLyric();
			}
		});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}
		
		super.update(elapsed);
	}
}
