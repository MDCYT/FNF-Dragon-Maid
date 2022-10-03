package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxBasic;
import states.*;

import Shaders;

class Stage extends FlxTypedGroup<FlxBasic> {
  public static var songStageMap:Map<String,String> = [
    "serva" => 'kobayashi-house',
    "scaled" => 'kobayashi-house',
    "chaos-dragon" => 'kobayashi-house',
    "electro_trid3nt" => "forest",
    "killer-scream" => "kobayashi-house",
    "burn-it-all" => 'bad',
    "tutorial"=>"stage"
  ];

  public static var stageNames:Array<String> = [
    "stage",
    "kobayashi-house",
    "kobayashi-house-b",
    "forest",
    'bad'
  ];

  public var doDistractions:Bool = true;

  // misc, general bg stuff

  public var bfPosition:FlxPoint = FlxPoint.get(770,450);
  public var dadPosition:FlxPoint = FlxPoint.get(100,100);
  public var gfPosition:FlxPoint = FlxPoint.get(400,130);
  public var camPos:FlxPoint = FlxPoint.get(100,100);
  public var camOffset:FlxPoint = FlxPoint.get(100,100);

  public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
    "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
    "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
    "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
  ];
  public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
  public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still

  public var boppers:Array<Array<Dynamic>> = []; // should contain [sprite, bopAnimName, whichBeats]
  public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

  public var defaultCamZoom:Float = 1.05;

  public var curStage:String = '';

  //Tohru Var
  public var houseBump:FlxSprite;
	public var dragontendo:FlxSprite;
  public var house:FlxSprite;
  public var smoke:FlxSprite;
  public var chair:FlxSprite;
  public var black:FlxSprite;


  // other vars
  public var gfVersion:String = 'gf';
  public var gf:Character;
  public var boyfriend:Character;
  public var dad:Character;
  public var currentOptions:Options;
  public var centerX:Float = -1;
  public var centerY:Float = -1;

  override public function destroy(){
    bfPosition = FlxDestroyUtil.put(bfPosition);
    dadPosition = FlxDestroyUtil.put(dadPosition);
    gfPosition = FlxDestroyUtil.put(gfPosition);
    camOffset =  FlxDestroyUtil.put(camOffset);

    super.destroy();
  }

  public function setPlayerPositions(?p1:Character,?p2:Character,?gf:Character){

    if(p1!=null)p1.setPosition(bfPosition.x,bfPosition.y);
    if(gf!=null)gf.setPosition(gfPosition.x,gfPosition.y);
    if(p2!=null){
      p2.setPosition(dadPosition.x,dadPosition.y);
      camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
    }

    if(p1!=null){
      switch(p1.curCharacter){

      }
    }

    if(p2!=null){

      switch(p2.curCharacter){
        case 'gf':
          if(gf!=null){
            p2.setPosition(gf.x, gf.y);
            gf.visible = false;
          }
    
            PlayState.daCharacterPause = 0;
          case 'tohru_furious':
            camPos.x += 180;
            camPos.y -= 550;
    
            PlayState.daCharacterPause = 0;
          case 'elma':
            PlayState.daCharacterPause = 1;
      }
    }

    if(p1!=null){
      p1.x += p1.posOffset.x;
      p1.y += p1.posOffset.y;
    }
    if(p2!=null){
      p2.x += p2.posOffset.x;
      p2.y += p2.posOffset.y;
    }


  }

  public function new(stage:String,currentOptions:Options){
    super();
    if(stage=='halloween')stage='spooky'; // for kade engine shenanigans
    curStage=stage;
    this.currentOptions=currentOptions;

    overlay.scrollFactor.set(0,0); // so the "overlay" layer stays static

    switch (stage){

      case 'kobayashi-house':
        defaultCamZoom = 0.55;

        if (StoryMenuState.isMaid)
          {
            bfPosition.x += 290;
            bfPosition.y += 7;
            gfVersion = 'gf-maid';
          }
          else
          {
            bfPosition.x += 330;
            bfPosition.y += 74;
            gfVersion = 'gf-house';
  
          }
        
        gfPosition.y += 45;
        gfPosition.x += 50;

			  house = new FlxSprite(-1000, -235).loadGraphic(Paths.image('maidDragon/house/bg'));
        house.scale.set(1.15, 1.15);
        house.antialiasing = true;
			  house.updateHitbox();
			  add(house);

			  dragontendo = new FlxSprite(1760, 260).makeGraphic(185, 261, FlxColor.TRANSPARENT);
			  dragontendo.updateHitbox();

			  add(dragontendo);

      case 'kobayashi-house-b':

        defaultCamZoom = 0.65;

        if (StoryMenuState.isMaid)
          {
            bfPosition.x += 330;
            bfPosition.y -= 20;
            gfVersion = 'gf-scaredmaid';
          }
          else
          {
            bfPosition.x += 330;
            bfPosition.y += 78;
            gfVersion = 'gf-scared';
  
          }

        gfPosition.y += 25;
				gfPosition.x -= 95;

       // dadPosition.x -= 540;
        //dadPosition.y -= 680;

			  house = new FlxSprite(-800, -200).loadGraphic(Paths.image('maidDragon/house/bgc'));
			  house.scale.set(0.8, 0.8);
			  house.updateHitbox();
			  add(house);

			  dragontendo = new FlxSprite(1780, 400).loadGraphic(Paths.image('maidDragon/house/dragontendo'));
			  dragontendo.alpha = 0;
			  dragontendo.scale.set(0.8, 0.8);
			  dragontendo.updateHitbox();

			  var daBump:String;
			  var daX:Int;
			  var daY:Int;

			  switch (PlayState.SONG.song.toLowerCase())
			  {
				  case "chaos-dragon":
					  daBump = 'phase3';
				  	daX = 35;
					  daY = 220;
				  default: 
					  daBump = 'phase4';
					  daX = 35;
					  daY = 220;
		  	}

			  houseBump = new FlxSprite(daX, daY);
			  houseBump.frames = Paths.getSparrowAtlas('maidDragon/house/' + daBump);
			  houseBump.animation.addByPrefix('bump', 'bumpinkanna', 24, false);
			  houseBump.scale.set(0.7, 0.7);
			  houseBump.antialiasing = true;
			  houseBump.updateHitbox();
			  add(houseBump);

			  add(dragontendo);
      
      case 'forest':
        gfVersion = 'bfBeat';
        defaultCamZoom = 0.65;

        dadPosition.y = 121;
			  dadPosition.x = 40;

        bfPosition.x += 300;
				bfPosition.y += 20;
				gfPosition.x -= 50;
				gfPosition.y -= 50;
			
			  var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('maidDragon/forest/bgForest'));
        bg.scrollFactor.set();
			  bg.screenCenter();

			  var base:FlxSprite = new FlxSprite(0, -400).loadGraphic(Paths.image('maidDragon/forest/bgBase'));
        base.setGraphicSize(Std.int(base.width * 1.3));
        base.updateHitbox();
			  base.screenCenter(X);
		  	add(bg);
			  add(base);
      
      case 'bad':
        defaultCamZoom = 0.80;
        bfPosition.x = 267;
        bfPosition.y = 982;
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.scrollFactor.set();
        bg.screenCenter();
        add(bg);


      default:
        defaultCamZoom = 1;
        curStage = 'stage';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains','shared'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      }
  }


  public function beatHit(beat){

    switch (curStage)
		{
		}
  }

  override function update(elapsed:Float){

    super.update(elapsed);
  }

  var startedMoving:Bool = false;
}
