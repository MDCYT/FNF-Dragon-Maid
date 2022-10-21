package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteGroup;
using StringTools;
import flixel.util.FlxTimer;
import ui.*;
class ShopState extends MusicBeatState
{
	var curSelected:Int = 0;

	var lblmoney:FlxText;

	var cat:FlxSprite;
	var info:FlxTypeText;
	var fafnir:FlxSprite;
	
	var obj:FlxSpriteGroup;

	var ind:FlxSprite;
	var ct:FlxText;
	var bar:FlxSprite;

	public static var item:Array<Dynamic> = [
		['fire', 'Reduced miss damage and increased health. \nThis power-up does not protect you from damage caused by trap arrows.'],
		['fire', 'It protects you from trap arrows and their effects. \nIt is an excellent power-up for "Chaos" difficulty.'],
		['arrow', 'This power-up will unlock the blocked arrows, \nhowever it is not necessary to be in "Burst Mode" to take effect'],
		['fire', 'Increased score, miss damage and any drown null.\nDoes not protect you from trap arrows or insta-kill.'],
		['arrow', 'Rewards for songs, weeks and mini-games are increased as long as you have it equipped.'],
		['arrow', 'Equipped decreases the amount of combos needed to reach "Burst Mode".'],
		['arrow', 'Increases the duration of the "Burst Mode" 5 more sections.'],
		['arrow', 'Increases the duration of the "Burst Mode" 10 more sections.'],
		['fire', 'Will nullify/omit any effect of a currently active fire trap arrow.'],
		['key', '"Killer-Scream" Extra song available in Freeplay.'],
		['key', 'BF and GF "Maid" skin, available for use on any difficulty.']
	];

	override function create(){
		super.create();

		if(FlxG.save.data.coin == null){FlxG.save.data.coin = 0;}

		#if desktop DiscordClient.changePresence("Shop", null); #end

		var bg:FlxBackdrop = new FlxBackdrop(CoolUtil.getBitmap(Paths.image('shopState/bg')), 10, 0, true, false);
		bg.antialiasing = true;
		bg.velocity.set(-50, 0);
		add(bg);

		var ov:FlxSprite = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('shopState/overlay1')));
		ov.antialiasing = true;
		add(ov);

		var sh:FlxSprite = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('shopState/shapes')));
		sh.antialiasing = true;
		add(sh);

		var box:FlxSprite = new FlxSprite(0, 483).loadGraphic(CoolUtil.getBitmap(Paths.image('shopState/box')));
		box.screenCenter(X);
		box.antialiasing = true;
		add(box);

		cat = new FlxSprite(135, 509);
		cat.frames = Paths.getSparrowAtlas('shopState/category');
		cat.animation.addByPrefix('arrow', 'arrow');
		cat.animation.addByPrefix('fire', 'fire');
		cat.animation.addByPrefix('key', 'key');
		cat.scale.set(0.2, 0.2);
		cat.updateHitbox();
		cat.antialiasing = true;
		add(cat);

		info = new FlxTypeText(133, 564, 681, '', 23);
		info.font = Paths.font('scoreFont.ttf');
		info.color = FlxColor.WHITE;
		add(info);

		fafnir = new FlxSprite(828, 117);
		fafnir.frames = Paths.getSparrowAtlas('shopState/fafnir');
		fafnir.scale.set(0.73, 0.73);
		fafnir.animation.addByPrefix('talk', 'talk', 24, true);
		fafnir.animation.addByPrefix('idle', 'idle', 15, true);
		fafnir.animation.play('idle');
		fafnir.updateHitbox();
		fafnir.antialiasing = true;
		add(fafnir);

		obj = new FlxSpriteGroup();
		add(obj);

		for(i in 0...item.length){
			var it:FlxSprite = new FlxSprite(337, 153).loadGraphic(CoolUtil.getBitmap(Paths.image('shopState/catalogue/${i}')));
			it.scale.set(0.6, 0.6);
			it.updateHitbox();
			it.antialiasing = true;
			it.ID = i;
			obj.add(it);
			//FlxMouseEventManager.add(menuItem,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
		}

		bar = new FlxSprite(0, 60).loadGraphic(CoolUtil.getBitmap(Paths.image('shopState/barCoin')));
		bar.antialiasing = true;
		add(bar);

		lblmoney = new FlxText(bar.x + 10, bar.y + 15, '${FlxG.save.data.coin}', 32);
		lblmoney.font = Paths.font('scoreFont.ttf');
		lblmoney.color = FlxColor.PURPLE;
		add(lblmoney);
		
		ind = new FlxSprite(435, 30).loadGraphic(CoolUtil.getBitmap(Paths.image('shopState/ind')));
		ind.antialiasing = true;
		FlxTween.tween(ind, {y: ind.y + 10}, 10, {type:FlxTween.PINGPONG, ease:FlxEase.backInOut});
		add(ind);

		var blackUpFront = new FlxSprite().makeGraphic(FlxG.width, 40, FlxColor.BLACK); add(blackUpFront);
		var blackDownFront = new FlxSprite(0, FlxG.height - 40).makeGraphic(FlxG.width, 40, FlxColor.BLACK); add(blackDownFront);

		changeItem();
	}

	override function beatHit(){
		super.beatHit();
	}
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.LEFT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(-1);
		}

		if (FlxG.keys.justPressed.RIGHT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(1);
		}
		super.update(elapsed);
	}

	function changeItem(huh:Int = 0,force:Bool=false)
	{
		if(force){
			curSelected=huh;
		}else{
			curSelected += huh;

			if (curSelected >= obj.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = obj.length - 1;
		}

		var en:Array<String> = item[curSelected];

		fafnir.animation.play('talk');
		info.setBorderStyle(OUTLINE, FlxColor.PURPLE, 1.5);
		info.resetText(en[1]);
		info.start(0.03, true);
		info.completeCallback = function () {
			fafnir.animation.play('idle');
		}
		cat.animation.play(en[0]);

		obj.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0;
			if (spr.ID == curSelected) {
				spr.alpha = 1;
				spr.scale.set(0.6, 0.6);
				spr.updateHitbox();
				spr.setPosition(337, 156);
			}
			else if (spr.ID == curSelected - 1) {
				spr.alpha = 0.6;
				spr.scale.set(0.55, 0.55);
				spr.updateHitbox();
				spr.setPosition(64, 175);
			}
			else if (spr.ID == curSelected + 1) {
				spr.alpha = 0.6;
				spr.scale.set(0.55, 0.55);
				spr.updateHitbox();
				spr.setPosition(626, 175);
			}
			
			spr.updateHitbox();
		});
	}
}
