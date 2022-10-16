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
  public var table:FlxSprite;

  //Elma var

  public var base:FlxSprite;
  public var moun:FlxSprite;
  public var cloud:FlxSprite;
  public var bg:FlxSprite;


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
            camPos.x += 300;
            camPos.y += 60;
            PlayState.daCharacterPause = 1;
          default:
            PlayState.daCharacterPause = 0;
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
            bfPosition.y += 115;
            dadPosition.y += 30;
            dadPosition.x -= 5;
            gfVersion = 'gf-house';
  
          }
        
        gfPosition.y += 45;
        gfPosition.x += 50;

			  house = new FlxSprite(-1000, -235).loadGraphic(Paths.image('maidDragon/house/bg'));
        house.scale.set(1.15, 1.15);
        house.antialiasing = true;
			  house.updateHitbox();
			  add(house);

        table = new FlxSprite().loadGraphic(Paths.image('maidDragon/house/table'));
        table.antialiasing = true;
        table.updateHitbox();
        add(table);

			  dragontendo = new FlxSprite(1760, 260).makeGraphic(185, 261, FlxColor.TRANSPARENT);
			  dragontendo.updateHitbox();

			  add(dragontendo);
      case 'forest':
        gfVersion = 'bfBeat';
        defaultCamZoom = 0.47;

        dadPosition.x = -726;
        dadPosition.y = 520;

        bfPosition.x = 882;
        bfPosition.y = 823;
        
        gfPosition.x -= 175;
        gfPosition.y += 408;
			
			  bg = new FlxSprite(-1230, 0).loadGraphic(Paths.image('maidDragon/forest/bgForest'));
        bg.scale.set(1.2, 1.1);
        bg.scrollFactor.set(0.95, 0.95);
        bg.antialiasing = true;
			  bg.updateHitbox();
        trace(bg);

			  cloud = new FlxSprite(-100, -25).loadGraphic(Paths.image('maidDragon/forest/cloud'));
        cloud.scale.set(1.1, 1.1);
        cloud.scrollFactor.set(0.95, 0.95);
        cloud.antialiasing = true;
        cloud.updateHitbox();

        moun = new FlxSprite(-1426, -120).loadGraphic(Paths.image('maidDragon/forest/mountains'));
        moun.scale.set(1.3, 1.3);
        moun.antialiasing = true;
        moun.updateHitbox();

        base = new FlxSprite(-1365, -220).loadGraphic(Paths.image('maidDragon/forest/bgBase'));
        base.scale.set(1.5, 1.5);
        base.antialiasing = true;
        base.updateHitbox();

		  	add(bg);
        add(cloud);
        add(moun);
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
