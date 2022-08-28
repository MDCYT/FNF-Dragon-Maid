package ui;

import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import states.*;

class MaidUi extends FlxSpriteGroup {
  public var score:FlxSprite;
  public var bgBar:FlxSprite;
  public var bar:FlxBar;
  public var iconP1:HealthIcon;
  public var txt:FlxText;

  public var value:Float = 2;

  var display:Float = 2;
  var instance:FlxBasic;
  var property:String;
  public function new(x:Float, y:Float, player1:String, ?instance:FlxBasic, ?property:String, min:Float=0, max:Float=2, baseColor:FlxColor=0xFFFF0000){
    super(x,y);
    if(property==null || instance==null){
      property='value';
      instance=this;
    }

    this.instance=instance;
    this.property=property;
    display = Reflect.getProperty(instance,property);

    var loadAnim:String = 'Bf';

    switch(player1){
      case 'bf':
        loadAnim = 'Bf';
      case 'gf':
        loadAnim = 'Gf';
    }

    score = new FlxSprite();
    score.frames = Paths.getSparrowAtlas('maidUi/Score');
    score.animation.addByPrefix('score', 'scoreUi' + loadAnim);
    score.animation.play('score');
    score.updateHitbox();
    score.antialiasing = true;

    bgBar = new FlxSprite(score.x - 60, score.y + 14).loadGraphic(Paths.image('maidUi/bar'));
    bgBar.antialiasing = true;
    bgBar.updateHitbox();

    bar = new FlxBar(bgBar.x + 20, bgBar.y + 86, RIGHT_TO_LEFT, 572, 21, this, 'display', min, max);
    bar.angle = -15;
    bar.createFilledBar(baseColor,FlxColor.WHITE);

    iconP1 = new HealthIcon(player1, true);
    iconP1.y = score.y + 78;
    iconP1.x = score.x + 308;
    iconP1.updateHitbox();

    txt = new FlxText(score.x + 206, score.y + 153, 0, "");
		txt.setFormat(Paths.font('megaton.ttf'), 60, baseColor, LEFT);
    txt.angle = -11;

    add(score);
    add(bar);
    add(bgBar);
    add(iconP1);
    add(txt);

  }
  public function setIcons(?player1,?player2){
    player1=player1==null?iconP1.animation.curAnim.name:player1;
    iconP1.changeCharacter(player1);
  }

  public function setColors(baseColor:FlxColor){
    txt.color = baseColor;
    bar.createFilledBar(FlxColor.WHITE, baseColor);
  }
  
  public function setScore(score:Int){
    txt.text =  ${score};
  }
  public function setIconSize(iconP1Size:Int){
    iconP1.setGraphicSize(Std.int(iconP1Size));

    iconP1.updateHitbox();
  }
  public function beatHit(curBeat:Float){
    setIconSize(Std.int(iconP1.width+15));
  }

  override function update(elapsed:Float){
    var num = Reflect.getProperty(instance,property);
    display=num;
      //display = FlxMath.lerp(display,num,Main.adjustFPS(.2));
      //if(Math.abs(display-num)<.1){
        //display=num;
      //}
    
    //}else{
    //}

    var percent = bar.percent;
    var opponentPercent = 100-bar.percent;
    setIconSize(Std.int(FlxMath.lerp(iconP1.width, 100, Main.adjustFPS(0.1))));
    var iconOffset:Int = 26;

    if (percent < 20 && iconP1.lossIndex!=-1)
      iconP1.animation.curAnim.curFrame = iconP1.lossIndex;
    else if(percent > 80 && iconP1.winningIndex!=-1)
      iconP1.animation.curAnim.curFrame = iconP1.winningIndex;
    else
      iconP1.animation.curAnim.curFrame = iconP1.neutralIndex;

    super.update(elapsed);

  }
}
