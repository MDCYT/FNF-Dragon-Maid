package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import lime.utils.Assets;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.text.FlxTypeText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import ui.*;
using StringTools;
 
class ExtraState extends MusicBeatState
{
	var trans:MaidTransition;
    var extraOptions:Array<String> = ['art', 'music', 'mini', 'credits'];
	var extraChar:Array<String> = ['bf', 'gf', 'koba', 'koba'];
	var dialog:Array<String> = [
	"This is the art gallery, look at the sketches and interesting things of the mod here!", 
	"Listen to all the mod soundtracks here", 
	"Play the hidden minigames in the weeks, you won't earn coins if you play them here",
	"Thank you for supporting the proyect, we'll be bringing more advances!"
	];
	var textColor:Array<FlxColor> = [0xFF3b578f, 0xFF703466, 0xFF788300, 0xFF8a442a];
	
	var optionGrp:FlxTypedGroup<ExtrasThing>;
	var grpBg:FlxTypedGroup<ExtrasBg>;
	var grpChar:FlxTypedGroup<ExtrasChar>;
	var boxGrp:FlxTypedGroup<FlxSprite>;

    var curSelected:Int = 0;
	var tween:Bool = true;

	var defCam:FlxCamera;
	var camBg:FlxCamera;
	var camChar:FlxCamera;
	var camOp:FlxCamera;
	var camTran:FlxCamera;

	var dialogText:FlxTypeText;

    override public function create():Void
    {   
		super.create();

		trans = new MaidTransition(0, 0);
		trans.screenCenter();

		defCam = new FlxCamera();

        camBg = new FlxCamera();
		camBg.bgColor.alpha = 0;

        camChar = new FlxCamera();
		camChar.bgColor.alpha = 0;

		camTran = new FlxCamera();
		camTran.bgColor.alpha = 0;

        FlxG.cameras.reset(defCam);

        FlxG.cameras.add(camBg);
		FlxG.cameras.add(camChar);
		FlxG.cameras.add(camTran);

        FlxCamera.defaultCameras = [defCam];

		dialogText = new FlxTypeText(120, 522, 600, '', 32);
		dialogText.font = Paths.font('assFont.ttf');
		dialogText.color = FlxColor.WHITE;

		grpBg = new FlxTypedGroup<ExtrasBg>();
		add(grpBg);

		grpChar = new FlxTypedGroup<ExtrasChar>();
		add(grpChar);

		optionGrp = new FlxTypedGroup<ExtrasThing>();
		add(optionGrp);

		boxGrp = new FlxTypedGroup<FlxSprite>();
		add(boxGrp);

		for (i in 0...extraOptions.length)
		{
			var bg:ExtrasBg = new ExtrasBg(10, 0, extraOptions[i]);
			bg.ID = i;
			bg.animation.play('bg');
			bg.updateHitbox();
			grpBg.add(bg);

			var image:ExtrasThing = new ExtrasThing(0, 100 + (i * 80), extraOptions[i]);
            image.targetY = i;
			image.animation.play('off');
			image.updateHitbox();
			optionGrp.add(image);

			var char:ExtrasChar = new ExtrasChar(0, 0, extraChar[i]);
			char.ID = i;
			char.animation.play('idle');
			char.updateHitbox();
			grpChar.add(char);

			var box:FlxSprite = new FlxSprite(79, 504);
			box.frames = Paths.getSparrowAtlas('extraState/bg/box');
			box.animation.addByPrefix('box', 'box ' + extraOptions[i]);
			box.updateHitbox();
			box.antialiasing = true;
			box.animation.play('box');
			boxGrp.add(box);

			/*FlxTween.tween(image, {y:image.y + 100 + (i * 120)}, (i* 0.5), {ease:FlxEase.expoInOut, onComplete: function(twn:FlxTween){
				tween = true;
			}});*/
        }

		add(dialogText);
		add(trans);

		grpBg.cameras = [camBg];
		boxGrp.cameras = [camBg];
		optionGrp.cameras = [camBg];
		dialogText.cameras = [camBg];
		grpChar.cameras = [camChar];
		trans.cameras = [camTran];

		camChar.setPosition(399, 190);

        changeSelection();
		trans.transOut();
        
    }

    function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = extraOptions.length - 1;
		if (curSelected >= extraOptions.length)
			curSelected = 0;

		dialogText.setBorderStyle(OUTLINE, textColor[curSelected], 2.5);
		dialogText.resetText(dialog[curSelected]);
		dialogText.start(0.03, true);

		switch (curSelected)
		{
			case 0:
				camChar.setPosition(399, 190);
			case 1:
				camChar.setPosition(380, 108);
			case 2:
				camChar.setPosition(430, 65);
			case 3:
				camChar.setPosition(430, 65);
		}

        var bullShit:Int = 0;

		for (item in optionGrp.members)
		{
			item.targetY = bullShit - curSelected;

			if (item.targetY == Std.int(0))
			{
				item.alpha = 1;
				item.animation.play('on');
			}
			else
			{
				item.alpha = 0.5;
				item.animation.play('off');
			}
			bullShit++;
		}

		var daItem:Int = 0;

		grpBg.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0;
			grpChar.members[daItem].alpha = 0;
			boxGrp.members[daItem].alpha = 0;
			spr.updateHitbox();
			spr.animation.pause();

			if (spr.ID == curSelected)
			{
				grpChar.members[curSelected].alpha = 1;
				boxGrp.members[curSelected].alpha = 1;
				spr.alpha = 1;
				spr.animation.resume();
			}
			
			daItem ++;
		});
    }

	var daCam:Int = 0;

    override public function update(elapsed:Float):Void
    {   

		if (FlxG.mouse.justPressedRight)
		{
			daCam ++;
			if (daCam >= 4)
				daCam = 0;
		}

		if (FlxG.mouse.pressed)
		{
			dialogText.setPosition(FlxG.mouse.x, FlxG.mouse.y);
			trace(dialogText.x + ' '+ dialogText.y);
		}
        var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (tween)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				trans.transIn('main');
			}
		
			if (controls.ACCEPT)
			{	
				tween = false;
				FlxG.sound.play(Paths.sound('pressEnter'));
		
				var dalol:String = extraOptions[curSelected];
		
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{		
					switch (dalol)
					{
						case 'art':
							trans.transIn('art');
						case 'music':
							trans.transIn('playlist');
						case 'mini':
							FlxG.switchState(new MiniselecState());
					}
				});
			}
		}
		

        super.update(elapsed);
    }
}