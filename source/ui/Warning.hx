package ui;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import states.*;

class Warning extends FlxSpriteGroup {
  public var rect:FlxSprite;
  public var gf:FlxSprite;
  public var title:FlxText;
  public var hassGf:Bool = false;
  public var hassBtn:Bool = false;
  public var btn:Button;
  public var sound:String = 'ann';
  var escencials:FlxSpriteGroup;
  public var warning:Array<String> = [
    "no digas eso papu :'v",

    "Could not establish a connection to the network \n try to connect later.
    The data obtained during the games \n will not be saved in the online ranking",

    "Could not connect to the server \n try again later",

    "Are you sure you want to enter the charting state? \n
    Your score, coins and achievements \n will not be saved if you continue."
    
    ];
  
  public function new(x:Float, y:Float, hasGf:Bool = false, hasBtn:Bool = false){
    super(x,y);
    hassGf = hasGf;
    hassBtn = hasBtn;

    rect = new FlxSprite();
    rect.frames = Paths.getSparrowAtlas('mainMenu/warning');
    rect.animation.addByPrefix('warning', 'warning');
    rect.animation.addByPrefix('tutorial', 'tutorial');
    rect.animation.addByPrefix('intro', 'intro');
    rect.animation.addByPrefix('info', 'info');
    rect.updateHitbox();
    rect.screenCenter();
    rect.antialiasing = true;

    title = new FlxText(0, 280, 554, warning[0]);
    title.setFormat(Paths.font('warning.ttf'), 23, FlxColor.BLACK, CENTER);
    title.updateHitbox();
    title.screenCenter(X);
    
    this.alpha = 0;

    escencials = new FlxSpriteGroup();
    escencials.add(rect);
    escencials.add(title);

    if(hasBtn){
      btn = new Button(rect.x + 150, 470);
      trace(btn.x);
      escencials.add(btn);
    }
    escencials.scale.set(0, 0);

    add(escencials);

    if(hasGf){
      gf = new FlxSprite(990, 505);
      gf.frames = Paths.getSparrowAtlas('mainMenu/gf_emotes');
      gf.animation.addByPrefix('point', 'gf ie 1', 30);
      gf.animation.addByPrefix('smile', 'gf ie 2', 30);
      gf.animation.addByPrefix('sad', 'gf ie 3', 30);
      gf.animation.addByPrefix('verySad', 'gf ie 4', 30);
      gf.animation.addByPrefix('pog', 'gf ie 5', 30);
      gf.scale.set(0.4, 0.4);
      gf.updateHitbox();
      gf.alpha = 0;
      gf.antialiasing = true;

      add(gf);
    }

  }

  public function setWarn(num:Int = 0, type:String = 'intro', ?gfAnim:String = 'smile', ?typeBtn:Int) {
    rect.animation.play(type);
    title.text = warning[num];

    if (hassGf){
      gf.animation.play(gfAnim);
      switch(gfAnim){
          case 'smile':
              gf.setPosition(990, 506);
          case 'pog':
              gf.setPosition(1030, 505);
          case 'point':
              gf.setPosition(1030, 510);
          case 'sad':
              gf.setPosition(1030, 510);
          case 'verySad':
              gf.setPosition(1030, 510);
      }
    }

    if(hassBtn){
      btn.createBtn(typeBtn, type);
    }

    switch(type){
      case 'warning':
        sound = 'warn';
      default:
        sound = 'ann';
    }
  }

  public function popUp() {
    FlxG.sound.play(Paths.sound(sound));
    this.alpha = 1;
    escencials.scale.set(0, 0);
    FlxTween.tween(escencials.scale, {x: 1, y: 1}, 0.7, {ease: FlxEase.elasticOut});
  }

  public function popOut() {
    escencials.scale.set(1, 1);
    FlxTween.tween(escencials.scale, {x: 0, y: 0}, 0.2, {ease: FlxEase.expoOut, onComplete: function (_) {
      this.alpha = 0;
    }});
  }
  
  override function update(elapsed:Float){

    if (hassBtn && this.alpha == 1){
      if (FlxG.keys.justPressed.LEFT)
        {
          FlxG.sound.play(Paths.sound('annScroll'));
          btn.changeItem(-1);
        }
  
        if (FlxG.keys.justPressed.RIGHT)
        {
          FlxG.sound.play(Paths.sound('annScroll'));
          btn.changeItem(1);
        }
    }
    super.update(elapsed);
  }
}

class Button extends FlxSpriteGroup{
  var btnGrp:FlxSpriteGroup;
  var textGrp:FlxSpriteGroup;
  var ifBtn:Bool = false;
  public var curSelected:Int = 0;
  var options:Array<Dynamic> = [
    ['NO', 'YES'], 
    ['CANCEL', 'ACCEPT'], 
    ['RETRY', 'ACCEPT'], 
    ['OK'],
    ['NEXT', 'SKIP TUTORIAL'],
    ['NEXT']
  ];

  public function new(x:Float, y:Float)
  {
    super(x, y);
    btnGrp = new FlxSpriteGroup();
    textGrp = new FlxSpriteGroup();
    add(btnGrp);
    add(textGrp);
  }

  public function createBtn(type:Int = 0, theme:String = '') {

    var opt:Array<String> = options[type];   

    for (i in 0...opt.length){
      var btn:FlxSprite = new FlxSprite(0 + (i * 300));
      btn.frames = Paths.getSparrowAtlas('mainMenu/warningBtn');
      btn.animation.addByPrefix('off', theme + 'Off');
      btn.animation.addByPrefix('on', theme + 'On');
      btn.animation.play('off');
      btn.updateHitbox();
      btn.antialiasing = true;
      btn.ID = i;

      var stamp:FlxText = new FlxText(btn.x - 545 + (i * 5), 22, FlxG.width, opt[i]);
      stamp.setFormat(Paths.font('warning.ttf'), 23, FlxColor.BLACK, CENTER);
      stamp.setBorderStyle(OUTLINE, FlxColor.WHITE, 1);
      stamp.updateHitbox();

      if (type == 3 || type == 5){
        trace('hola');
        ifBtn = true;
        btn.x = 145;
        stamp.x = btn.x - 528;

        btn.updateHitbox();
        stamp.updateHitbox();
      }
      else ifBtn = false;

      btnGrp.add(btn);
      textGrp.add(stamp);
    }
    
    changeItem();
  }

  public function changeItem(huh:Int = 0)
  {
      curSelected += huh;

      if (curSelected >= btnGrp.length)
        curSelected = 0;
      if (curSelected < 0)
        curSelected = btnGrp.length - 1;

    btnGrp.forEach(function(spr:FlxSprite)
    {
      spr.animation.play('off');
      spr.y = 470;
      if (!ifBtn) spr.x = 382 + (spr.ID * 300);
      textGrp.members[spr.ID].scale.set(1, 1);

      if (spr.ID == curSelected)
      {
        spr.animation.play('on');
        spr.y = 454;
        if (!ifBtn) spr.x = 368 + (curSelected * 300);
        FlxTween.tween(textGrp.members[curSelected].scale, {x: 1.05, y: 1.05}, 0.3, {ease:FlxEase.expoOut});
      }

      spr.updateHitbox();
    });
  }
}
