package states;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
import flixel.FlxCamera;
using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var trans:MaidTransition;
	var pauseCam:FlxCamera;

	public static var firstPlay:Bool = true;
	public static var notAgainPLZ:Bool = false;

	var bg:FlxSprite;

	var pauseMusic:FlxSound;
	var countingDown:Bool=false;

	public function new(x:Float, y:Float)
	{
		pauseCam = new FlxCamera();
		pauseCam.bgColor.alpha = 0;
		FlxG.cameras.add(pauseCam);

		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('pauseMaid'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		trans = new MaidTransition(0, 0);
		trans.screenCenter();
		add(trans);
	}


	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);


		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

}
