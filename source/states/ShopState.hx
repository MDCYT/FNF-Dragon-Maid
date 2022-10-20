package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import openfl.display.Shader;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import io.newgrounds.NG;
import lime.app.Application;
import Shaders;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
import flixel.input.mouse.FlxMouseEventManager;
import ui.*;
class ShopState extends MusicBeatState
{
	var curSelected:Int = 0;

	var obj:FlxSpriteGroup;

	/*function onMouseDown(object:FlxObject){
		if(!selectedSomethin){
			if(object==gfDance){
				var anims = ["singUP","singLEFT","singRIGHT","singDOWN"];
				var sounds = ["GF_1","GF_2","GF_3","GF_4"];
				var anim = FlxG.random.int(0,3);
				gfDance.holdTimer=0;
				gfDance.playAnim(anims[anim]);
				FlxG.sound.play(Paths.sound(sounds[anim]));
			}else{
				for(obj in menuItems.members){
					if(obj==object){
						accept();
						break;
					}
				}
			}
		}
	}

	function onMouseUp(object:FlxObject){

	}

	function onMouseOver(object:FlxObject){
		if(!selectedSomethin){
			for(idx in 0...menuItems.members.length){
				var obj = menuItems.members[idx];
				if(obj==object){
					if(idx!=curSelected){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(idx,true);
					}
				}
			}
		}
	}

	function onMouseOut(object:FlxObject){

	}
*/
	override function create()
	{
		super.create();
		#if desktop
		DiscordClient.changePresence("Shop", null);
		#end

		var bg:FlxSprite = new FlxBackdrop(Paths.image('shopState/bg'), 10, 0, true, false);
		bg.velocity.set(-150, 0);
		add(bg);

		obj = new FlxSpriteGroup();
		add(obj);

		for (i in 0...optionShit.length)
			{
				var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
				//FlxMouseEventManager.add(menuItem,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
			}

		changeItem();
	}

	override function beatHit(){
		super.beatHit();
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
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

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
