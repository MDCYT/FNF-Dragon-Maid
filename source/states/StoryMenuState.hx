package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flash.events.MouseEvent;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import EngineData.WeekData;
import EngineData.SongData;
import ui.*;
using StringTools;

class StoryMenuState extends MusicBeatState
{
	var bg:FlxBackdrop;
	var trans:MaidTransition;
	var scoreText:FlxText;

	var curDifficulty:Int = 0;

	public static var weekUnlocked:Array<Bool> = [true, true, true];

	var nameData:Array<String> = ['tutorial', 'week1', 'week2'];

	var curWeek:Int = 0;

	var grpWeekText:FlxTypedGroup<FlxSprite>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var camDiff:FlxCamera;
	var defCam:FlxCamera;

	var diffselect:Bool = false;
	var yPos:Int = 320;

	var camFollow:FlxObject;
	var score:FlxText;

	var bgBlack:FlxSprite;
	var diffThing:FlxSprite;

	var scrollDiff:Bool = false;
	var changeDiff:Bool = false;
	var scrollUp:Bool = false;

	public static var isMaid:Bool = false;
	public static var unlockedMaid:Bool = false;
	
	var weekData:Array<WeekData>;

	override function create()
	{
		super.create();

		defCam = new FlxCamera();

        camDiff = new FlxCamera();
		camDiff.bgColor.alpha = 0;

        FlxG.cameras.reset(defCam);
		FlxG.cameras.add(camDiff);

        FlxCamera.defaultCameras = [defCam];

		weekData = EngineData.weekData;

		weekUnlocked = EngineData.weeksUnlocked;

		trans = new MaidTransition(0, 0);
		trans.screenCenter();
		trans.scrollFactor.set();

		bg = new FlxBackdrop(CoolUtil.getBitmap(Paths.image('storyMode/background')), 10, 0, true, false);
		bg.velocity.set(-150, 0);
		bg.scrollFactor.set();
		add(bg);

		bgBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgBlack.alpha = 0;
		bgBlack.scrollFactor.set();

		diffThing = new FlxSprite(0, 0).loadGraphic(CoolUtil.getBitmap(Paths.image('storyMode/diffThing')));
		diffThing.screenCenter(X);
		diffThing.scrollFactor.set();
				
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		persistentUpdate = persistentDraw = true;

		score = new FlxText(0, 10, FlxG.width, "WEEK SCORE:", 36);
		score.setFormat("Claphappy", 32, CENTER);
		score.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		score.scrollFactor.set();

		scoreText = new FlxText(0, score.y + 37, FlxG.width, "SCORE: 49324858", 36);
		scoreText.setFormat("Claphappy", 32, CENTER);
		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		scoreText.scrollFactor.set();

		var ui_tex = Paths.getSparrowAtlas('storyMode/storyDiff');

		grpWeekText = new FlxTypedGroup<FlxSprite>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var tex = Paths.getSparrowAtlas('storyMode/storyThing');
		
		for (i in 0...weekData.length - 2)
		{
			var weekThing:FlxSprite = new FlxSprite(40, 60 + (i * 320));
			weekThing.frames = tex;
			weekThing.animation.addByPrefix('idle', nameData[i] + " off", 24);
			weekThing.animation.addByPrefix('selected', nameData[i] + " on", 24);
			weekThing.updateHitbox();
			weekThing.animation.play('idle');
			weekThing.ID = i;
			grpWeekText.add(weekThing);
			weekThing.antialiasing = true;

			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width - 650, weekThing.health);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		add(diffThing);

		FlxG.camera.follow(camFollow, null, 0.06);

		changeWeek();

		add(bgBlack);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		sprDifficulty = new FlxSprite(483, yPos);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.scrollFactor.set();
		
		sprDifficulty.animation.addByPrefix('harmony', 'HARMONY');
		sprDifficulty.animation.addByPrefix('chaos', 'CHAOS');
		sprDifficulty.screenCenter(X);
		sprDifficulty.animation.play('harmony');
		sprDifficulty.updateHitbox();
		difficultySelectors.add(sprDifficulty);

		leftArrow = new FlxSprite(sprDifficulty.x - 125, sprDifficulty.y);
		leftArrow.frames = ui_tex;
		leftArrow.scrollFactor.set();
		leftArrow.updateHitbox();
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		rightArrow = new FlxSprite(sprDifficulty.x + 385, sprDifficulty.y);
		rightArrow.frames = ui_tex;
		rightArrow.scrollFactor.set();
		rightArrow.updateHitbox();
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(scoreText);
		add(score);

		updateText();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		score.cameras = [camDiff];
		scoreText.cameras = [camDiff];
		diffThing.cameras = [camDiff];
		difficultySelectors.cameras = [camDiff];
		camDiff.y = -1000;

		add(trans);
		trans.transOut();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, Main.adjustFPS(0.5)));

		scoreText.text = '' + lerpScore;

		difficultySelectors.visible = (weekUnlocked[curWeek] || !EngineData.mustUnlockWeeks);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek && !scrollDiff && !scrollUp)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}
			}

			if (scrollDiff)
			{
				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');
	
				if (controls.LEFT )
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');
	
				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (!diffselect)
			{
				if (controls.ACCEPT)
				{
					selecDiff(true);
				}

				if (controls.BACK && !movedBack && !selectedWeek)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					movedBack = true;
					trans.transIn('main');
				}
			}
			else
			{
				if (controls.ACCEPT)
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					selectWeek();
				}

				if (controls.BACK)
				{
					selecDiff(false);
				}
			}
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek] || !EngineData.mustUnlockWeeks)
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('pressEnter'));
				stopspamming = true;
			}

			selectedWeek = true;

			isMaid = false;

			switch (curDifficulty)
			{
				case 1:
					isMaid = true;
				default:
					isMaid = false;
			}

			PlayState.setStoryWeek(weekData[curWeek],curDifficulty);

			FlxG.sound.music.fadeOut(1.0);
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new LoadingSubState());
				//LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (FlxG.save.data.maidDiff)
		{
			if (curDifficulty < 0)
				curDifficulty = 1;
			if (curDifficulty > 1)
				curDifficulty = 0;
		}
		else
		{
			curDifficulty = 0;
		}

		sprDifficulty.offset.x = 0;
		sprDifficulty.offset.y = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('harmony');
				leftArrow.color = 0xFFf6ff00;
				rightArrow.color = 0xFFf6ff00;
				sprDifficulty.offset.x -= 112;
				sprDifficulty.offset.y -= 10;
			case 1:
				sprDifficulty.animation.play('chaos');
				leftArrow.color = 0xFFff002a;
				rightArrow.color = 0xFFff002a;
				sprDifficulty.offset.x -= 176;
				sprDifficulty.offset.y -= 10;

		}
		sprDifficulty.alpha = 0;
		sprDifficulty.y = yPos - 15;

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		FlxTween.tween(sprDifficulty, {x: sprDifficulty.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length - 2)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 2;

		if (curWeek >= 3){
			curWeek = 2;
		}

		trace(curWeek);

		grpWeekText.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
	
			if (spr.ID == curWeek)
			{
				spr.animation.play('selected');

				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
			spr.updateHitbox();
		});

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	function selecDiff(go:Bool)
	{
		if (go)
		{
			diffselect = true;
			scrollUp = true;
			changeDifficulty();
			FlxTween.tween(bgBlack, {alpha: 0.7}, 0.3, {ease: FlxEase.quartInOut, onComplete: function(flxTween:FlxTween){

				FlxTween.tween(camDiff, {y: camDiff.y + 1000}, 0.4, {ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween){
						scrollDiff = true;
						changeDiff = true;	
				}});
			}});
		}
		else
		{
			scrollDiff = false;

			FlxTween.tween(camDiff, {y: diffThing.y - 1000}, 0.2, {ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween){

				FlxTween.tween(bgBlack, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, onComplete: function(flxTween:FlxTween){
					diffselect = false;
					scrollUp = false;
				}});
			}});
		}
	}

	override function switchTo(next:FlxState){
		// Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState

		return super.switchTo(next);
	}

}
