package states;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import Options;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;
import flash.events.MouseEvent;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxState;
import openfl.Lib;
import EngineData.WeekData;
import EngineData.SongData;
import haxe.Json;
import sys.io.File;
import openfl.Lib;
import flixel.system.FlxSound;
import openfl.media.Sound;
import ui.*;
#if cpp
import Sys;
import sys.FileSystem;
#end
import CoinBar;


using StringTools;

typedef ExternalSongMetadata = {
	@:optional var displayName:String;
	@:optional var freeplayIcon:String;
	@:optional var inFreeplay:Bool;

}

class FreeplayState extends MusicBeatState
{
	var trans:MaidTransition;
	var songs:Array<SongData> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var selectableDiffs:Array<Int>=[0, 1];
	var difficulties:Array<Array<Int>> = [];
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var curDifficultyIdx:Int = 0;
	var intendedScore:Int = 0;
	var songText:FreePlayThing;
	var theColor:Int = 0;
	var noise:FlxSound;
	var pause:Bool = false;

	var bg:FlxBackdrop;
	var isSus:Bool = false;
	var colorBg:Array<FlxColor> = [0xFFff334b, 0xFFffdb51, 0xFF87a6fa, 0xFFa34d9a ,0x000000];
	//var songs:Array<String> = ['Tutorial', 'serva', 'scaled', 'electro_trid3nt', 'killer-scream'];
	var disco:FlxSprite;

	var playSong:Bool = false;
	var framework:FlxSprite;
	var art:FlxSprite;
	var circle:FlxSprite;
	var weeks:Int = 1;
	var unlock:Bool = FlxG.save.data.bad;

	var songNames:Array<String>=[];

	private var grpSongs:FlxTypedGroup<FreePlayThing>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		super.create();

		PlayState.lifes = 3;
		
		if (PlayState.bad)
			PlayState.bad = false;

		if (Lib.current.stage.window.borderless){
			Lib.current.stage.window.borderless = false;
		}

		Lib.current.stage.window.title = TitleState.title + ' - Freeplay';
		trans = new MaidTransition(0, 0);
		trans.screenCenter();
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end
		/*
		for (i in 0...initSonglist.length)
		{
			var data = initSonglist[i].split(" ");
			var icon = data.splice(0,1)[0];
			songs.push(new SongMetadata(data.join(" "), 1, icon));
		}
		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky','spooky','monster']);

		if (StoryMenuState.weekUnlocked[3] || isDebug)
			addWeek(['Pico', 'Philly-Nice', 'Blammed'], 3, ['pico']);

		if (StoryMenuState.weekUnlocked[4] || isDebug)
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState.weekUnlocked[5] || isDebug)
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		if (StoryMenuState.weekUnlocked[6] || isDebug)
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit'])
		*/

		for(i in 0...EngineData.weekData.length - weeks){
			addWeekData(EngineData.weekData[i]);
		}

		if (unlock){
			addSong('burn-it-all', 4, 'dragon', 'burn-it-all');
			weeks = 0;
		}
		/*var otherSongs = Paths.getDirs("songs","assets");

		for(song in otherSongs){
			//addSong(songName:String, weekNum:Int, songCharacter:String, ?chartName:String)
			if(!songNames.contains(song.toLowerCase())){
				var hasCharts:Bool = false;
				var icon:String = 'dad';
				var add:Bool = true;
				var display:Null<String>=null;
				var songFolder = 'assets/songs/${song.toLowerCase()}';
				if(FileSystem.exists(songFolder)) {
					var hasMetadata= FileSystem.exists('$songFolder/metadata.json');
					var metadata:Null<ExternalSongMetadata> = null;
					if(hasMetadata){
						trace('GOT METADATA FOR ${song}');
						metadata = Json.parse(File.getContent('$songFolder/metadata.json'));

						add = metadata.inFreeplay==null?true:metadata.inFreeplay;
						icon = metadata.freeplayIcon==null?'dad':metadata.freeplayIcon;
						display = metadata.displayName;
						hasCharts=true;
					}else{
						if(FileSystem.exists(Paths.chart(song,song))){
							var song = Song.loadFromJson(song,song);
							icon = song==null?'dad':Character.getIcon(song.player2);
							if(icon==null)icon='dad';
							add=true;
							hasCharts=true;
						}
					}

					if(FileSystem.exists(Paths.chart(song,song)) && !hasCharts){
						hasCharts=true;
					}

					if(add && hasCharts)
						addSong(display==null?song.replace("-"," "):display,0,icon,song);

				}

			}
		}

		*/
		// LOAD MUSIC

		// LOAD CHARACTERS

		if (unlock){
			noise = new FlxSound();
			noise = FlxG.sound.play(Paths.music('noise'), 1, true);
			noise.volume = 0;
		}

		bg = new FlxBackdrop(Paths.image('maidMenu/freeplayBG'), 10, 0, true, false);
		bg.velocity.set(-40, 0);
		bg.scale.set(1.05, 1.05);
		bg.antialiasing = true;
		add(bg);

		circle = new FlxSprite().loadGraphic(Paths.image('maidMenu/circle'));
		circle.antialiasing = true;
		circle.alpha = 0;
		add(circle);

		art = new FlxSprite().loadGraphic(Paths.image('maidMenu/freeplayArt0'));
		art.antialiasing = true;
		add(art);


		FlxTween.tween(art, {x: art.x + 30}, 4, {ease:FlxEase.expoInOut, type:PINGPONG});

		grpSongs = new FlxTypedGroup<FreePlayThing>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			songText = new FreePlayThing(0, 0, songs[i].displayName);
			songText.targetY = i;
			grpSongs.add(songText);
			trace(songText.targetY);
			trace(songText.frames);
			trace(songs[i].displayName);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("Square.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.x = 80;
		scoreText.y = 670;

		diffText = new FlxText(10, 0 + 36, 0, "", 35);
		diffText.font = scoreText.font;

		framework = new FlxSprite().loadGraphic(Paths.image('maidMenu/freeplay_framwork'));

		disco = new FlxSprite(960, 443);
		disco.frames = Paths.getSparrowAtlas('maidMenu/freeplayArt');
		disco.updateHitbox();
		disco.antialiasing = true;
		disco.animation.addByPrefix('art0', 'art0', 24);
		disco.animation.addByPrefix('art1', 'art1', 24);
		disco.animation.addByPrefix('art2', 'art2', 24);
		disco.animation.addByPrefix('art3', 'art3', 24);
	
		add(framework);
		add(diffText);
		add(scoreText);
		add(disco);

		changeSelection();
		changeDiff(1);

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		add(trans);
		trans.transOut();
	}

	public function addSongData(songData:EngineData.SongData){
		songNames.push(songData.chartName.toLowerCase());
		songs.push(songData);
		var songDiffs:Array<Int> = [];
		if(FileSystem.isDirectory('assets/songs/${songData.chartName.toLowerCase()}') ){
			for (file in FileSystem.readDirectory('assets/songs/${songData.chartName.toLowerCase()}'))
			{
				if(file.endsWith(".json") && !FileSystem.isDirectory(file)){
					var difficultyName = file.replace(".json","").replace(songData.chartName.toLowerCase(),"");
					switch(difficultyName.toLowerCase()){
						case '-harmony':
							songDiffs.push(0);
						case '-chaos':
							songDiffs.push(1);
					}
				}
			}

			songDiffs.sort((a,b)->Std.int(a-b));

			difficulties.push(songDiffs);
		}else{
			difficulties.push([1,0]);
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, ?chartName:String)
	{
		addSongData(new SongData(songName,songCharacter,weekNum,chartName));
	}

	public function addWeekData(weekData:WeekData){
		for(song in weekData.songs){
			addSongData(song);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}
	function selectSong(){

		FlxTransitionableState.skipNextTransOut = true;
		
		if (songs[curSelected].displayName == 'killer-scream' && FlxG.save.data.killer){
			StoryMenuState.isMaid = false;
			curDifficulty = 0;
		}

		if (songs[curSelected].displayName == 'burn-it-all'){
			StoryMenuState.isMaid = false;
			PlayState.bad = true;
			curDifficulty = 0;
		}
		 
		else{
			switch (curDifficulty)
			{
				case 1:
					StoryMenuState.isMaid = true;
				default:
					StoryMenuState.isMaid = false;
			}
		}

		if (songs[curSelected].displayName == 'killer-scream' && !FlxG.save.data.killer){
			CoinBar.purchase(10000, 'killers');
			changeSelection();
		}
		else{
			FlxG.sound.play(Paths.sound('pressEnter'));
			FlxG.sound.music.fadeOut(1.0);
			FlxG.camera.fade(FlxColor.WHITE, 1.5, false, function() {
				PlayState.setFreeplaySong(songs[curSelected],curDifficulty);
				LoadingState.loadAndSwitchState(new PlayState());	
			});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.save.data.killer){

		}

		disco.angle += 1;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, Main.adjustFPS(0.4)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(-1);

		if (controls.BACK)
		{
			if (pause){
				FlxG.sound.resume();
				noise.pause();
			}
			trans.transIn('main');
		}

		if (FlxG.keys.justPressed.SPACE)
			playTheSong();

		if (accepted)
		{
			selectSong();
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficultyIdx += change;

		if (FlxG.save.data.maidDiff)
		{
			if(curDifficultyIdx > 1){
				curDifficultyIdx = 0;
			}else if(curDifficultyIdx < 0){
				curDifficultyIdx = selectableDiffs.length - 1;
			}
		}
		else
		{
			curDifficultyIdx = 0;
		}
		
		var oldDiff = curDifficulty;

		curDifficulty = selectableDiffs[curDifficultyIdx];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].chartName, curDifficulty);
		#end
		switch (curDifficulty)
		{
			case 0:
				diffText.text = "Difficulty: << HARMONY >>";
			case 1:
				diffText.text = "Difficulty: << CHAOS >>";
		}

		if (theColor == 3) diffText.text = "Difficulty: << KILLER >>";
		if (theColor == 4) diffText.text = "null";
	}

	function changeSelection(change:Int = 0,additive:Bool=true)
	{
		#if !switch
		//NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if(additive){
			curSelected += change;

			if (curSelected < 0 && !FlxG.save.data.badDragon)
				curSelected = 4;
			else if (curSelected < 0 && FlxG.save.data.badDragon)
				curSelected = 5;
			if (curSelected >= songs.length)
				curSelected = 0;
		}else{
			curSelected=change;
		}

		trace(curSelected);

		selectableDiffs=difficulties[curSelected];
		if(selectableDiffs.contains(curDifficulty)){
			curDifficultyIdx = selectableDiffs.indexOf(curDifficulty);
		}else{
			if(curDifficultyIdx>selectableDiffs.length){
				curDifficultyIdx=0;
			}else if(curDifficultyIdx<0){
				curDifficultyIdx=selectableDiffs.length;
			}
			curDifficulty=selectableDiffs[curDifficultyIdx];
			if(!selectableDiffs.contains(curDifficulty)){
				curDifficultyIdx=selectableDiffs.contains(1)?selectableDiffs.indexOf(1):selectableDiffs[Std.int(selectableDiffs.length/2)];
				curDifficulty=selectableDiffs[curDifficultyIdx];
			}
		}

		var songIs:String = songs[curSelected].displayName;

		switch (songIs)
		{
			case 'serva' | 'scaled' | 'chaos-dragon':
				theColor = 1;
			case 'electro_trid3nt':
				theColor = 2;
			case 'killer-scream':
				theColor = 3;
			case 'burn-it-all':
				theColor = 4;
			default:
			 	theColor = 0;
		};

		if (unlock){
			if (songIs == 'burn-it-all'){
				FlxG.sound.pause();
				noise.play();
				noise.volume = 1;
				pause = true;
			}
			else{
				if (pause){
					FlxG.sound.resume();
					pause = false;
				}
				noise.pause();
			}
		}

		changeDiff();

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].chartName, curDifficulty);
		// lerpScore = 0;
		#end

		var createThread=false;
		#if sys
			createThread=true;
		#end

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.x = 0;
				FlxTween.tween(item, {x: item.x - 40}, 0.2, {ease: FlxEase.expoInOut});
			}
			else
			{
				item.x = 0;
			}
		}

		trace(theColor);

		FlxTween.color(bg, 0.3, bg.color, colorBg[theColor], {ease:FlxEase.expoInOut});
		FlxTween.color(art, 0.3, bg.color, colorBg[theColor], {ease:FlxEase.expoInOut});
		FlxTween.color(circle, 0.3, circle.color, colorBg[theColor], {ease:FlxEase.expoInOut});

		disco.animation.play('art' + theColor);
	}

	function playTheSong()
	{
		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.full(songs[curSelected].displayName), 0);
		#end
	}

	override function switchTo(next:FlxState){

		return super.switchTo(next);
	}
}
