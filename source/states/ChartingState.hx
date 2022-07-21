package states;

import Options;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import Song.VelocityChange;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import openfl.media.Sound;
import ui.*;
using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:NoteGraphic;
	var dummyArrowLayer:FlxTypedGroup<NoteGraphic>;
	var useHitSounds = false;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<Note>;
	var curRenderedMarkers:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;
	var quantization:Int = 16;
	var quantIdx = 3;
	var quantizations:Array<Int> = [
		4,
		8,
		12,
		16,
		20,
		24,
		32,
		48,
		64,
		96,
		192
	];

	var _song:SwagSong;
	var velChanges:Array<VelocityChange> = [];
	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;
	var recentNote:Array<Dynamic>;
	var curSelectedMarker:VelocityChange;


	var tempBpm:Int = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var startPos:Float = 0;

	public function new(?pos:Float){
		super();
		startPos=pos;
	}

	override function create()
	{
		super.create();
		InitState.getCharacters();
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<Note>();
		curRenderedMarkers = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null){
			_song = PlayState.SONG;
			velChanges=_song.sliderVelocities;
			_song.sliderVelocities=null;
		}else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: "stage",
				noteModifier: "base",
				speed: 1,
				validScore: false
			};
			velChanges = [];
		}

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrowLayer = new FlxTypedGroup<NoteGraphic>();
		add(dummyArrowLayer);
		dummyArrow = new NoteGraphic(0,PlayState.noteModifier,EngineData.options.noteSkin,Note.noteBehaviour);
		dummyArrow.setDir(0,false,false);
		dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
		dummyArrow.updateHitbox();
		dummyArrow.alpha=.5;
		dummyArrowLayer.add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Marker", label: 'Marker'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addMarkerUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedMarkers);
		curSection = 0;

		vocals.time = startPos;
		FlxG.sound.music.time = startPos;
		Conductor.songPosition = startPos;
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();
		while (curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		updateSectionUI();


	}

	function addSongUI():Void
	{
		var UI_songTitle = new Inputbox(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var check_mute_vox = new FlxUICheckBox(10, 175, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vox.checked = false;
		check_mute_vox.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_vox.checked)
				vol = 0;

			vocals.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = EngineData.characters;

		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});

		player2DropDown.selectedLabel = _song.player2;

		var stageDropdown = new FlxUIDropDownMenu(10, 240, FlxUIDropDownMenu.makeStrIdLabelArray(Stage.stageNames, true), function(stageName:String)
		{
			_song.stage = Stage.stageNames[Std.parseInt(stageName)];
		});

		stageDropdown.selectedLabel = _song.stage;

		// TODO: noteskin.noteModifiers or some shit
		var modifiers:Array<String> = CoolUtil.coolTextFile(Paths.txt('noteModifiers'));
		var modifierDropdown = new FlxUIDropDownMenu(140, 240, FlxUIDropDownMenu.makeStrIdLabelArray(modifiers, true), function(mod:String)
		{
			_song.noteModifier = modifiers[Std.parseInt(mod)];
		});

		modifierDropdown.selectedLabel = _song.noteModifier;

		var check_use_hit = new FlxUICheckBox(135, 200, null, null, "Use hit sounds (in editor)", 100);
		check_use_hit.checked = false;
		check_use_hit.callback = function()
		{
			useHitSounds=check_use_hit.checked;
		};

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vox);
		tab_group_song.add(check_use_hit);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(stageDropdown);
		tab_group_song.add(modifierDropdown);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}
	var markerScrollMult:FlxUINumericStepper;
	var markerSnap:FlxUICheckBox;
	function addMarkerUI():Void
	{
		var tab_group_marker = new FlxUI(null,UI_box);
		tab_group_marker.name = 'Marker';

		markerScrollMult = new FlxUINumericStepper(10, 10, .1, 0, -10, 10, 1);
		markerScrollMult.value = 1;
		markerScrollMult.name = 'marker_scrollVel';

		markerSnap = new FlxUICheckBox(10, 35, null, null, "Snap to mouse", 100);
		markerSnap.checked = false;

		tab_group_marker.add(markerScrollMult);
		tab_group_marker.add(markerSnap);
		UI_box.addGroup(tab_group_marker);
	}

	var stepperSusLength:FlxUINumericStepper;

	var placingType:FlxUIDropDownMenu;
	var noteType:FlxUIDropDownMenu;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		/*
		var modifiers:Array<String> = CoolUtil.coolTextFile(Paths.txt('noteModifiers'));
		var modifierDropdown = new FlxUIDropDownMenu(140, 240, FlxUIDropDownMenu.makeStrIdLabelArray(modifiers, true), function(mod:String)
		{
			_song.noteModifier = modifiers[Std.parseInt(mod)];
		});
		*/

		noteType = new FlxUIDropDownMenu(10, 125, FlxUIDropDownMenu.makeStrIdLabelArray(EngineData.noteTypes, true), function(type:String){
			if(curSelectedNote!=null){
				curSelectedNote[3] = type;
				updateNoteUI();
				updateGrid();
			}
		});
		noteType.selectedLabel = EngineData.noteTypes[0];

		placingType = new FlxUIDropDownMenu(150, 125, FlxUIDropDownMenu.makeStrIdLabelArray(EngineData.noteTypes, true), function(type:String){
			dummyArrowLayer.remove(dummyArrow);
			var type = EngineData.noteTypes[Std.parseInt(type)];
			var behaviour = type=='default'?Note.noteBehaviour:Note.behaviours.get(type);
			if(behaviour==null){
				behaviour = Json.parse(Paths.noteSkinText("behaviorData.json",'skins',EngineData.options.noteSkin,PlayState.noteModifier,type));
				Note.behaviours.set(type,behaviour);
			}
			dummyArrow = new NoteGraphic(0,PlayState.noteModifier,EngineData.options.noteSkin,type,behaviour);
			dummyArrow.setDir(0,false,false);
			dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
			dummyArrow.updateHitbox();
			dummyArrow.alpha=.5;
			dummyArrowLayer.add(dummyArrow);
		});

		placingType.selectedLabel = EngineData.noteTypes[0];

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');
		tab_group_note.add(noteType);
		tab_group_note.add(placingType);
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(CoolUtil.getSound('${Paths.inst(daSong)}'), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(CoolUtil.getSound('${Paths.voices(daSong)}'));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/*
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'marker_scrollVel')
			{
				curSelectedMarker.multiplier=nums.value;
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime(?section:Int):Float
	{
		if(section==null)section=curSection;

		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}
	function sectionEndTime(?section:Int):Float
	{
		if(section==null)section=curSection;
		return sectionStartTime(section+1);
	}

	var lastMousePos:FlxPoint = FlxPoint.get();

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if(FlxG.keys.justPressed.RIGHT){
			quantIdx+=1;
			if(quantIdx>quantizations.length-1)
				quantIdx = 0;

			quantization = quantizations[quantIdx];
		}

		if(FlxG.keys.justPressed.LEFT){
			quantIdx-=1;
			if(quantIdx<0)
				quantIdx = quantizations.length-1;

			quantization = quantizations[quantIdx];
		}

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}


		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note) || CoolUtil.truncateFloat(note.strumTime,2) == CoolUtil.truncateFloat(getStrumTime(dummyArrow.y),2) && note.rawNoteData==Math.floor(FlxG.mouse.x / GRID_SIZE) )
					{
						trace(note.strumTime,note.rawNoteData);
						if (FlxG.keys.pressed.CONTROL)
						{
							trace("tryin to select note...");
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}else if (FlxG.mouse.overlaps(curRenderedMarkers)){
				curRenderedMarkers.forEach( function(mark:FlxSprite)
				{
					if (FlxG.mouse.overlaps(mark))
					{
						if(FlxG.keys.pressed.CONTROL){
							selectMarker(mark);
						}else{
							deleteMarker(mark);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote(FlxG.mouse.justPressedRight);
				}
			}
		}

		if(FlxG.mouse.justReleased || FlxG.mouse.justReleasedRight){
			recentNote=null;
		}else if(FlxG.mouse.pressed || FlxG.mouse.pressedRight){
			if(recentNote!=null){
				if(lastMousePos.y!=dummyArrow.y){
					lastMousePos.set(dummyArrow.x,dummyArrow.y);
					var length = getStrumTime(dummyArrow.y)-(recentNote[0]-sectionStartTime());
					setNoteSustain(length,recentNote);
				}
			}
		}

		if(FlxG.keys.justPressed.M){
			addScrollChange();
		}

		curRenderedNotes.forEach(function(note:Note){
			if(note.strumTime<=Conductor.songPosition){
				if(note.color!=0xAAAAAA){
					if(!note.wasGoodHit){
						note.wasGoodHit=true;
						if(useHitSounds){
							if(note.rawNoteData<=3)
								FlxG.sound.play(Paths.sound('Normal_Hit'),3);
						}
					}

					note.color = 0xAAAAAA;
				}

			}else{
				note.wasGoodHit=false;
				note.color = 0xFFFFFF;
			}
		});

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			var time = getStrumTime(FlxG.mouse.y);
			var beat = Conductor.getBeat(time);
			var snap = 4/quantization;
			var x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			var y = getYfromStrum(Conductor.beatToSeconds(Math.floor(beat / snap) * snap));
			if (FlxG.keys.pressed.SHIFT)
				y = FlxG.mouse.y;

			if(dummyArrow.y!=y || dummyArrow.x!=x){
				var beat = Conductor.getBeatInMeasure(getStrumTime(y) + sectionStartTime());
				var quant = Note.getQuant(beat);
				if(dummyArrow.quantTexture!=quant){
					dummyArrow.quantTexture = quant;

					dummyArrow.setTextures();
				}
				dummyArrow.setDir(Math.floor(FlxG.mouse.x / GRID_SIZE)%4,false,false);
				dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
				dummyArrow.updateHitbox();
				dummyArrow.x = x;
				dummyArrow.y = y;
			}
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;
			var time = FlxG.sound.music.time;
			PlayState.setSong(_song);
			PlayState.SONG.sliderVelocities = velChanges;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.mouse.visible = false;
			if(FlxG.keys.pressed.SHIFT){
				PlayState.startPos = time;
			}else{
				PlayState.startPos = 0;
			}
			PlayState.inCharter=true;
			PlayState.charterPos = time;
			FlxG.switchState(new PlayState());
		}

		if(FlxG.keys.pressed.SHIFT){

		}else{
			if (FlxG.keys.justPressed.E)
			{
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q)
			{
				changeNoteSustain(-Conductor.stepCrochet);
			}
		}


		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
					vocals.time = FlxG.sound.music.time;
					FlxG.sound.music.time = vocals.time;
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.D){
			for(i in 0...shiftThing){
				if (_song.notes[curSection + i] == null)
				{
					addSection();
				}
			}
			changeSection(curSection + shiftThing);
		}
		if (FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);


		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nStep: "
			+ curStep
			+ "\nBeat: "
			+ curBeat
			+ "\nSnap: 1/"
			+ quantization + "\n(Press left/right to switch)";
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float,?note):Void
	{
		if(note==null)note=curSelectedNote;
		if(note==null)return;
		setNoteSustain(note[2]+value);
	}

	function setNoteSustain(value:Float,?note):Void
	{
		if(note==null)note=curSelectedNote;

		if (note != null)
		{
			if (note[2] != null)
			{
				note[2] = Math.max(value, 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
			for(i in curRenderedNotes){
				i.wasGoodHit=false;
			}
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.changeCharacter(Character.getIcon(_song.player1));
			rightIcon.changeCharacter(Character.getIcon(_song.player2));
			leftIcon.setGraphicSize(0, 45);
			rightIcon.setGraphicSize(0, 45);
		}
		else
		{
			leftIcon.changeCharacter(Character.getIcon(_song.player2));
			rightIcon.changeCharacter(Character.getIcon(_song.player1));
			leftIcon.setGraphicSize(0, 45);
			rightIcon.setGraphicSize(0, 45);
		}
	}

	function updateMarkerUI():Void
	{
		if (curSelectedMarker != null)
			markerScrollMult.value = curSelectedMarker.multiplier;
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null){
			stepperSusLength.value = curSelectedNote[2];
			noteType.selectedLabel = EngineData.noteTypes[curSelectedNote[3]];
		}
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (curRenderedMarkers.members.length > 0)
		{
			curRenderedMarkers.remove(curRenderedMarkers.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for(i in velChanges){
			if(i.startTime>=sectionStartTime() && i.startTime<sectionEndTime()){
				var marker = new FlxSprite(-50, 50).makeGraphic(64, 12);
				marker.health = i.startTime;
				marker.y = getYfromStrum((i.startTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
				curRenderedMarkers.add(marker);
			}
		}

		 var oldNote:Note;
		 for (i in sectionInfo)
 		{
 			var daNoteInfo = i[1];
 			var daStrumTime = i[0];
 			var daSus = i[2];

 			var note:Note = new Note(daStrumTime, daNoteInfo%4, EngineData.options.noteSkin, PlayState.noteModifier, EngineData.noteTypes[i[3]], null, false, 0, true);
			note.wasGoodHit = daStrumTime<Conductor.songPosition;
 			note.rawNoteData = daNoteInfo;
 			note.sustainLength = daSus;
 			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
 			note.updateHitbox();
 			oldNote=note;

 			note.x = Math.floor(daNoteInfo * GRID_SIZE);
 			note.y = getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

 			curRenderedNotes.add(note);
			if(!note.canHold)daSus=0;
 			if (daSus > 0)
 			{
 				/*var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
 					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
 				curRenderedSustains.add(sustainVis);*/
 				daSus = daSus/Conductor.stepCrochet;
 				var sus = [];
 				for (susNote in 0...Math.floor(daSus))
 				{
 					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteInfo % 4, EngineData.options.noteSkin, PlayState.noteModifier, EngineData.noteTypes[i[3]], oldNote, true,0,true);
 					sustainNote.rawNoteData = daNoteInfo;
 					sustainNote.setGraphicSize(GRID_SIZE, GRID_SIZE);
 					sustainNote.updateHitbox();
 					sustainNote.x = Math.floor(daNoteInfo * GRID_SIZE);
 					sustainNote.y = oldNote.y + GRID_SIZE;
 					sustainNote.flipY = false;
 					sustainNote.scale.y = 1;
 					oldNote = sustainNote;
 					curRenderedSustains.add(sustainNote);
 				}
 				for(i in curRenderedSustains){
					switch(i.noteType){
						default:
		 					if(i.animation.curAnim!=null && i.animation.curAnim.name.endsWith("end") ){
		 						if(PlayState.curStage.startsWith("school")){
		 							i.setGraphicSize(Std.int(GRID_SIZE*.35), Std.int(GRID_SIZE*.35));
		 							i.updateHitbox();
		 							i.offset.x = -17.25;
		 							i.offset.y = (GRID_SIZE*.35)/2-12;
		 						}else{
		 							i.setGraphicSize(Std.int(GRID_SIZE*.35), Std.int((GRID_SIZE)/2)+2);
		 							i.updateHitbox();
		 							i.offset.x = 5;
		 							i.offset.y = (GRID_SIZE)/2+2;
		 						}

		 						i.x = Math.floor(i.rawNoteData * GRID_SIZE);
		 					}else{
		 						i.setGraphicSize(Std.int(GRID_SIZE*.35), GRID_SIZE+1);
		 						i.updateHitbox();
		 						i.offset.x = 5;
		 						if(PlayState.curStage.startsWith("school")){
		 							i.offset.x = -17.25;
		 						}
		 						i.x = Math.floor(i.rawNoteData * GRID_SIZE);
		 					}
						}
					}
 				}
 			}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			trace(i[0],i[1],note.strumTime,note.rawNoteData);
			if (i[0] == note.strumTime && i[1] == note.rawNoteData)
			{
				curSelectedNote = i;
				lastMousePos.set(dummyArrow.x,dummyArrow.y);
				if(FlxG.mouse.pressed)
					recentNote = i;
			}
		}

		updateGrid();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == note.rawNoteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}
		updateMarkerUI();
		updateGrid();
	}

	function selectMarker(marker:FlxSprite):Void
	{
		for (i in velChanges)
		{
			if (marker.health == i.startTime)
			{
				curSelectedMarker = i;
			}
		}
		updateMarkerUI();
		updateGrid();
	}

	function deleteMarker(marker:FlxSprite):Void
	{
		for (i in velChanges)
		{
			if (marker.health == i.startTime)
			{
				velChanges.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addScrollChange():Void
	{
		var snapTo:Float = strumLine.y;
		if(markerSnap.checked)
			snapTo=FlxG.mouse.y;

		var noteStrum = getStrumTime(Math.floor(snapTo / GRID_SIZE) * GRID_SIZE) + sectionStartTime();

		if(FlxG.keys.pressed.CONTROL){
			noteStrum = getStrumTime(snapTo) + sectionStartTime();
		}
		for(i in velChanges){
			if(i.startTime==noteStrum){
				return;
			}
		}
		velChanges.push({
			startTime:noteStrum,
			multiplier:1,
		});
		curSelectedMarker=velChanges[velChanges.length-1];

		updateGrid();
		updateMarkerUI();
		autosaveSong();
	}

	private function addNote(rightClick:Bool):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		for(nD in _song.notes[curSection].sectionNotes){
			if(nD[0]==noteStrum && nD[1]==noteData){
				return;
			}
		}
		var noteSus = 0;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, Std.parseInt(placingType.selectedId)]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];
		recentNote = curSelectedNote;
		if(FlxG.keys.pressed.CONTROL){
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData+4)%8, noteSus, Std.parseInt(placingType.selectedId)]);
		}

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song,
			"sliderVelocities": velChanges,
		},"\t");
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song,
			"sliderVelocities": velChanges,
		};

		var data:String = Json.stringify(json,"\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
