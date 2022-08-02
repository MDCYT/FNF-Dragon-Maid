package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import ui.*;
class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var daTheme:String = '';
	var trans:MaidTransition;
	var defCam:FlxCamera;
	var camTran:FlxCamera;

	public function new(x:Float, y:Float)
	{

		defCam = new FlxCamera();
        FlxG.cameras.reset(defCam);

		camTran = new FlxCamera();
		camTran.bgColor.alpha = 0;

		FlxG.cameras.add(camTran);

        FlxCamera.defaultCameras = [defCam];

		defCam.zoom = 0.65;
		
		var daSONG = PlayState.SONG.song;
		var daBf:String = '';

		switch (daSONG)
		{
			case 'scaled'| 'serva':
				daBf = 'BF_Death';
				daTheme = 'game';

			case 'chaos-dragon':
				daBf = 'BF_Death';
				daTheme = 'chaos';

			case 'electro_trid3nt':
				if (StoryMenuState.isMaid){
					daBf = 'GFMaidDeath';
					daTheme = 'game';
				}
				else{
					daBf = 'GFDeath';
					daTheme = 'game';
				}
			case 'killer-scream':
				daBf = 'BF_Death';
				daTheme = 'killer';
			case 'burn-it-all':
				daBf = 'bfDragon';
				daTheme = 'bad';
			default:
				daBf = 'BF_Death';
				daTheme = 'game';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		var lost:String = '';

		if (daBf == 'GFDeath')
		{
			camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y + 10, 1, 1);
			lost = 'gf';
		}
		else if(daBf == 'GFMaidDeath'){
			camFollow = new FlxObject(bf.getGraphicMidpoint().x + 300, bf.getGraphicMidpoint().y, 1, 1);
			lost = 'gf';
		}
		else
		{
			camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
			lost = 'fnf';
		}

		add(camFollow);

		FlxG.sound.play(Paths.sound(lost + '_loss_sfx'));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		trans = new MaidTransition(0, 0);
		trans.scrollFactor.set();
		trans.screenCenter();
		add(trans);
		
		trans.cameras = [camTran];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK && !PlayState.bad)
		{
			skipBullshit();
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, Main.adjustFPS(0.01));
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music(daTheme + 'Over'));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(daTheme + 'OverEnd'));
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2.5, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}

	function skipBullshit():Void
	{
		if (!isEnding)
		{
			FlxG.sound.play(Paths.sound('fnf_skip_sfx'));
			isEnding = true;
			bf.playAnim('deathSkip', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(daTheme + 'OverSkip'));
			new FlxTimer().start(4, function(tmr:FlxTimer)
			{
				trans.transIn('main');
			});
		}
	}
}
