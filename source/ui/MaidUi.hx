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
  public var txtAcc:FlxText;
  public var acc:FlxSprite;
  public var value:Float = 2;
  public var accSpr:FlxSprite;

  ///group
  public var scoreGrp:FlxSpriteGroup;
  public var accGrp:FlxSpriteGroup;

  var rank:Array<String> = ["FC",
  "FC",
  "FC",
  "FC",
  "S+",
  "S",
  "S-",
  "A+",
  "A",
  "A-",
  "B+",
  "B",
  "B-",
  "C+",
  "C",
  "C-",
  "D+",
  "D"
  ];
  var accString:String = '';
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
    var secColor:FlxColor = 0xFF00a6e2;

    switch(player1){
      case 'bf':
        loadAnim = 'Bf';
        secColor = 0xFFa3024b;
      case 'gf':
        loadAnim = 'Gf';
        secColor = 0xFF00a6e2;
    }

    scoreGrp = new FlxSpriteGroup();
    accGrp = new FlxSpriteGroup();

    score = new FlxSprite();
    score.frames = Paths.getSparrowAtlas('maidUi/Score');
    score.animation.addByPrefix('score', 'scoreUi' + loadAnim);
    score.animation.play('score');
    score.updateHitbox();
    score.antialiasing = true;

    acc = new FlxSprite(-980, 20);
    acc.frames = Paths.getSparrowAtlas('maidUi/acc');
    acc.animation.addByPrefix('acc', 'acu' + loadAnim);
    acc.animation.play('acc');
    acc.updateHitbox();
    acc.antialiasing = true;

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

    txt = new FlxText(score.x - 160, score.y + 100.2, FlxG.width, "");
		txt.setFormat(Paths.font('megaton.ttf'), 60, baseColor, LEFT);
    txt.updateHitbox();
    txt.angle = -12.5;

    txtAcc = new FlxText(acc.x - 140, acc.y + 91, FlxG.width, "");
		txtAcc.setFormat(Paths.font('optimus.ttf'), 62, secColor, LEFT);
    txtAcc.updateHitbox();
    txtAcc.angle = -12;

    accSpr = new FlxSprite(-666, 123);
    accSpr.frames = Paths.getSparrowAtlas('maidUi/acc' + loadAnim);
    for (i in 0...rank.length){
      accSpr.animation.addByPrefix(rank[i], rank[i] + '0', 24, false);
    }
    accSpr.updateHitbox();
    accSpr.antialiasing = true;
    accSpr.scrollFactor.set();

    scoreGrp.add(score);
    scoreGrp.add(bar);
    scoreGrp.add(bgBar);
    scoreGrp.add(iconP1);
    scoreGrp.add(txt);

    accGrp.add(acc);
    accGrp.add(txtAcc);
    accGrp.add(accSpr);

    add(accGrp);
    add(scoreGrp);

  }
  public function setIcons(?player1,?player2){
    player1=player1==null?iconP1.animation.curAnim.name:player1;
    iconP1.changeCharacter(player1);
  }

  public function setColors(baseColor:FlxColor){
    txt.color = baseColor;
    bar.createFilledBar(FlxColor.WHITE, baseColor);
  }
  
  public function setScore(score:Int, acc:Float, grade:String){
    var anim:String = 'FC';
    switch (grade){
      case '☆☆☆☆' | "☆☆☆" | "": 
        anim = 'FC';
      case "☆" | "☆☆":
        anim = 'S+';
      default:
        anim = grade;
    }
    txt.text =  Std.string(score);
    txtAcc.text = Std.string(FlxMath.roundDecimal(acc, 1) + '%');
    accSpr.animation.play(anim);
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

    if (FlxG.keys.justPressed.UP) {
      txtAcc.angle ++;
      trace(txtAcc.angle);
    }
    if (FlxG.keys.justPressed.DOWN) {
      txtAcc.angle --;
      trace(txtAcc.angle);
    }

    if(FlxG.mouse.pressed){
      accSpr.setPosition(FlxG.mouse.x, FlxG.mouse.y);
      trace(accSpr.x + ' ' + accSpr.y);
    }

    super.update(elapsed);

  }
}
