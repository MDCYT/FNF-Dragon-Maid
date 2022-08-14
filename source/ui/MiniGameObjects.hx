package ui;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
//Extendeme estaaaaaaaaaa, es broma bb
class MiniGameObjects extends FlxTypedGroup<FlxBasic>
{
    //Solo por si acaso es mejor hacerlas publicas ajuaaa
     var wall:FlxSprite;
     var nube:FlxSprite;
     var arboles:FlxSprite;
     var arbustos:FlxSprite;
     var roundText:FlxText;
     var bestScoreText:FlxText;
     var shootText:FlxText;
     var scoreText:FlxText;
     var axisText:FlxText;
     var pointText:FlxText;
     var barHud:FlxSprite;
     public var dragon:Dragon;
     var mouse:FlxSprite;
     var title:FlxSprite;
     var fontPixel = Paths.font("8-bit-hud.ttf");
      var dragonHud:FlxSprite;
      var spawnX:Array<Int> = [-78, 1066, 1258, -223, 507, 504, -213, 1287];
      var spawnY:Array<Int> = [484, 509, -254, -305, 630, -287, 121, 139];
      var moveX:Array<Int> = [474, -71, 1086, -77, 1083, 1083, -71];
      var moveY:Array<Int> = [-153, -153, -153, -152, 152, 480, 461];
      var randomSpawn:Int;
      public var tween:FlxTween;
      var randomMove:Int;
      var ready:FlxSprite;
      var set:FlxSprite;
      var go:FlxSprite;
      var menuItems:FlxTypedGroup<FlxSprite>;
     

 

    public var medueleelpilin:Map<String,FlxTypedGroup<FlxBasic>> = [
        "capa1"=>new FlxTypedGroup<FlxBasic>(),
        "capa2"=>new FlxTypedGroup<FlxBasic>(), 
        "capa3"=>new FlxTypedGroup<FlxBasic>(), 
      ];
      var titleOp:Array<String> = ['play', 'exit'];

    public var txtID:Map<String,
		FlxText> = [];

    public var sprID:Map<String,
		FlxSprite> = [];

    public var sprGrpId:Map<String,FlxTypedGroup<FlxSprite>> = [];
    public function new() {
        super();

       
  
    }
    public function loadLevel(curLevel:Int = 1)
      {
        switch(curLevel)
        {
          case 1:
            wall = new FlxSprite().loadGraphic(Paths.image('miniDragon/Fondo'));
            wall.setGraphicSize(1280, 720);
            wall.screenCenter();
    
            nube = new FlxSprite();
            nube.frames = Paths.getSparrowAtlas('miniDragon/nubes');
            nube.animation.addByPrefix('nube', 'nube', 10, true);
            nube.animation.play('nube');
            nube.updateHitbox(); 
    
            arboles = new FlxSprite().loadGraphic(Paths.image('miniDragon/Arboles'));
            arboles.setGraphicSize(1280, 720);
            arboles.screenCenter();

            arbustos = new FlxSprite(420, 227).loadGraphic(Paths.image('miniDragon/Arbusto'));
            arbustos.setGraphicSize(1280, 720);
    
            barHud = new FlxSprite(0, 575).loadGraphic(Paths.image('miniDragon/hud/Hud'));
            barHud.screenCenter(X);
    
            pointText = new FlxText(0, 0, '100', 15);
            pointText.font = fontPixel;
            pointText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
            pointText.alpha = 0;
    
            axisText = new FlxText(0, 0, '', 30);
            axisText.font = fontPixel;
            axisText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
    
            shootText = new FlxText(-522, 595, FlxG.width, 'SHOOT');
            shootText.setFormat('Eight-Bit Madness.ttf', 78, CENTER);
            shootText.font = Paths.font("Eight-Bit Madness.ttf");
    
            scoreText = new FlxText(-60, 591, FlxG.width, 'SCORE');
            scoreText.setFormat('Eight-Bit Madness.ttf', 84, RIGHT);
            scoreText.font = Paths.font("Eight-Bit Madness.ttf");
    
            roundText = new FlxText(-526, 491, FlxG.width, 'SCORE');
            roundText.setFormat('Eight-Bit Madness.ttf', 84, CENTER);
            roundText.font = Paths.font("Eight-Bit Madness.ttf");
    
            bestScoreText = new FlxText(0, 591, FlxG.width, 'SCORE');
            bestScoreText.screenCenter(X);
            bestScoreText.setFormat('Pixel Emulator.otf', 32, CENTER);
            bestScoreText.font = Paths.font("Pixel Emulator.otf");
    
            bestScoreText.text = 'TOP SCORE = ' + FlxG.save.data.bestScore;
            bestScoreText.color = 0xFF66f72d;
    
            dragonHud = new FlxSprite(435, 589);
            dragonHud.frames = Paths.getSparrowAtlas('miniDragon/hud/DragonCounter');
    
            dragonHud.animation.addByIndices('10', 'DragonCounter',[0], '', 24, false);
            dragonHud.animation.addByIndices('9', 'DragonCounter',[1], '', 24, false);
            dragonHud.animation.addByIndices('8', 'DragonCounter',[2], '', 24, false);
            dragonHud.animation.addByIndices('7', 'DragonCounter',[3], '', 24, false);
            dragonHud.animation.addByIndices('6', 'DragonCounter',[4], '', 24, false);
            dragonHud.animation.addByIndices('5', 'DragonCounter',[5], '', 24, false);
            dragonHud.animation.addByIndices('4', 'DragonCounter',[6], '', 24, false);
            dragonHud.animation.addByIndices('3', 'DragonCounter',[7], '', 24, false);
            dragonHud.animation.addByIndices('2', 'DragonCounter',[8], '', 24, false);
            dragonHud.animation.addByIndices('1', 'DragonCounter',[9], '', 24, false);
            dragonHud.animation.addByIndices('0', 'DragonCounter',[10], '', 24, false);
    
            dragonHud.animation.play('10');
    
            title = new FlxSprite().loadGraphic(Paths.image('miniDragon/title'));
            title.screenCenter();
    
            dragon = new Dragon();
            dragon.frames = Paths.getSparrowAtlas('miniDragon/tohruPixel');
            dragon.animation.addByPrefix('mov', 'Tohru Dragon Hunt Tohru0', 24, true);
            dragon.animation.addByPrefix('die', 'Tohru Dragon Hunt Tohru die', 24, false);
            dragon.animation.addByPrefix('movgold', 'Tohru Dragon Hunt golden tohru0', 24, true);
            dragon.animation.addByPrefix('diegold', 'Tohru Dragon Hunt golden tohru die', 24, false);
            dragon.animation.play('mov');
            dragon.updateHitbox();
    
            mouse = new FlxSprite();
            mouse.frames = Paths.getSparrowAtlas('miniDragon/GunTohruPixel');
            mouse.animation.addByPrefix('idle', 'Mira', 24, true);
            mouse.animation.addByPrefix('gun', 'Disparo', 24, false);
            mouse.animation.play('idle');
            mouse.scale.set(0.1, 0.1);
            mouse.updateHitbox();
    
            ready = new FlxSprite().loadGraphic(Paths.image('miniDragon/hud/READY'));
            ready.setGraphicSize(Std.int(ready.width * 4));
            ready.updateHitbox();
            ready.screenCenter();
            ready.antialiasing = false;
            ready.alpha = 0;

            set = new FlxSprite().loadGraphic(Paths.image('miniDragon/hud/SET'));
            set.setGraphicSize(Std.int(set.width * 4));
            set.updateHitbox();
            set.screenCenter();
            set.antialiasing = false;
            set.alpha = 0;
    
            go = new FlxSprite().loadGraphic(Paths.image('miniDragon/hud/GO'));
            go.setGraphicSize(Std.int(go.width * 4));
            go.updateHitbox();
            go.screenCenter();
            go.antialiasing = false;
            go.alpha = 0;
    
            menuItems = new FlxTypedGroup<FlxSprite>();
            
                for (i in 0...titleOp.length)
                {
                    var menuItem:FlxSprite = new FlxSprite(549, 432 + (i * 50));
              menuItem.frames = Paths.getSparrowAtlas('miniDragon/titleSelect');
              menuItem.animation.addByPrefix('idle', titleOp[i] + " false", 24);
              menuItem.animation.addByPrefix('selected', titleOp[i] + " true", 24);
                    menuItem.animation.play('idle');
              menuItem.ID = i;
              menuItems.add(menuItem);
                }

                dragon = new Dragon();
                dragon.setPosition(spawnX[randomSpawn], spawnY[randomSpawn]);
    
            //Las capasssssss 
            medueleelpilin.get("capa1").add(wall);
            medueleelpilin.get("capa1").add(nube);
            medueleelpilin.get("capa1").add(arboles);
            medueleelpilin.get("capa1").add(dragon);
    
            medueleelpilin.get("capa1").add(arbustos);
            medueleelpilin.get("capa1").add(pointText);
            medueleelpilin.get("capa1").add(roundText);
    
            medueleelpilin.get("capa1").add(mouse);
            medueleelpilin.get("capa1").add(barHud);
            medueleelpilin.get("capa1").add(shootText);
            medueleelpilin.get("capa1").add(dragonHud);
            medueleelpilin.get("capa1").add(scoreText);
            medueleelpilin.get("capa1").add(title);
    
            medueleelpilin.get("capa1").add(menuItems);
            medueleelpilin.get("capa1").add(bestScoreText);
            medueleelpilin.get("capa1").add(axisText);
            medueleelpilin.get("capa1").add(go);
            medueleelpilin.get("capa1").add(set);
            medueleelpilin.get("capa1").add(ready);
        
            sprGrpId['menuItems'] = menuItems;
            sprID['go'] = go;
            sprID['ready'] = ready;
            sprID['set'] = set;
            sprID['wall'] = wall;
            sprID['nube'] = nube;
            sprID['arboles'] = arboles;
            sprID['barHud'] = barHud;
            sprID['dragonHud'] = dragonHud;
            sprID['title'] = title;
            sprID['mouse'] = mouse;
            sprID['arbustos'] = arbustos;
    
            txtID['shootText'] = shootText;
            txtID['scoreText'] = scoreText;
            txtID['pointText'] = pointText;
            txtID['roundText'] = roundText;
            txtID['bestScoreText'] = bestScoreText;
            txtID['axisText'] = axisText;
        }  
      }
  
    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}

class Dragon extends FlxSprite
{
    var spawnX:Array<Int> = [-78, 1066, 1258, -223, 507, 504, -213, 1287];
    var spawnY:Array<Int> = [490, 515, -254, -305, 630, -287, 121, 139];
    var randomSpawn:Int;
    public var tween:FlxTween;
    var randomMove:Float;
	public function new(?x:Float, ?y:Float)
	{
		super(x, y);
        randomSpawn = Std.random(8);
        randomMove = Std.random(7);
       frames = Paths.getSparrowAtlas('miniDragon/Tohru Dragon Hunt');
       animation.addByIndices('mov', 'mov',[0, 1], '', 10, true);
       animation.addByIndices('die', 'die',[0], '', 24, false);
       animation.addByIndices('movgold', 'movgold',[0, 1], '', 10, true);
       animation.addByIndices('diegold', 'diegold',[0], '', 24, false);
       animation.play('mov');
       setGraphicSize(Std.int(width * 3));
       updateHitbox();
	}

  var beMove:Float = 0;

    public function dragonMove(daSpawn:Float = 0)
        {
            tween = FlxTween.tween(this, {x: daSpawn - 50, y: Std.random(FlxG.height) - 150}, 0.55, {ease:FlxEase.smootherStepInOut, onComplete: function (twn:FlxTween){
                randomMove = Std.random(FlxG.width);
                checkOffset(randomMove);
            }});
        }

    public function checkOffset(offset:Float)
    {
      if (offset == beMove){
        randomMove = Std.random(FlxG.width);
        checkOffset(randomMove);
      } 
      else{
        if (this.x < randomMove)
          flipX = false;
        else
          flipX = true;

        dragonMove(randomMove);
        beMove = randomMove;
      }
    }
}
