package states;

#if desktop
import Discord.DiscordClient;
#end
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
import states.*;
import flixel.FlxCamera;
using StringTools;

class PlayStateWarning extends MusicBeatSubstate
{
	var cartel:Warning;
	var inWarn:Bool = false;
	var bg:FlxSprite;
	var posChart:Float = 0;
	public function new(x:Float, y:Float, chartingPos:Float)
	{
		super();

		posChart = chartingPos;
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6}, 0.5, {ease: FlxEase.quartInOut});

		cartel = new Warning(0, 0, false, true);
		cartel.antialiasing = true;
		add(cartel);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		createWarn(3, 'warning', null, 0);

	}

	function createWarn(dialog:Int = 0, type:String = 'warning', ?gfAnim:String = 'smile', ?typeBtn:Int) {
        if(!inWarn) cartel.setWarn(dialog, type, gfAnim, typeBtn);
        cartel.popUp();
        inWarn = true;
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);


		if (FlxG.keys.justPressed.ENTER && inWarn)
			{
				switch (cartel.btn.curSelected)
				{
					case 0:
						cartel.popOut();
						close();
					case 1:
						FlxG.switchState(new ChartingState(posChart));
	
						#if desktop
							DiscordClient.changePresence("Chart Editor", null, null, true);
						#end
						
				}
			}
	}

	override function destroy()
	{

		super.destroy();
	}

}
