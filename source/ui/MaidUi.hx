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
  public var disc:FlxSprite;
  public var goldenDisc:FlxSprite;

  ///group
  public var plusGrp:FlxSpriteGroup;
  public var scoreGrp:FlxSpriteGroup;
  public var accGrp:FlxSpriteGroup;

  var rank:Array<String> = ["S+","S+","S+","S+","S+","S","S-","A+","A","A-","B+","B","B-","C+","C","C-","D+","D"];
  var accString:String = '';
  var display:Float = 2;
  var instance:FlxBasic;
  var property:String;
  
  public var canPoint = true;
  public var pointCombo = 0;
  public var tempCombo = 0;
  private var tmrCombo:FlxTimer;

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
    var barColor:FlxColor = 0xFF00a6e2;

    trace(player1);

    switch(player1){
      case 'bf' | 'bfMaid-player':
        loadAnim = 'Bf';
        barColor = 0xFF00a6e2;
      case 'gf' | 'gf-maid':
        loadAnim = 'Gf';
        barColor = 0xFFa3024b;
    }

    scoreGrp = new FlxSpriteGroup();
    accGrp = new FlxSpriteGroup();
    plusGrp = new FlxSpriteGroup();

    score = new FlxSprite(849, 568);
    score.frames = Paths.getSparrowAtlas('maidUi/newMaidHud');
    score.animation.addByPrefix('score', 'hudBf');
    score.animation.play('score');
    score.scale.set(0.7, 0.7);
    score.updateHitbox();
    score.antialiasing = true;

    acc = new FlxSprite(-1, 537);
    acc.frames = Paths.getSparrowAtlas('maidUi/scoreChar');
    acc.animation.addByPrefix('acc', 'score' + loadAnim, 24, false);
    acc.animation.play('acc');
    acc.scale.set(0.6, 0.6);
    acc.updateHitbox();
    acc.antialiasing = true;

    disc = new FlxSprite(1120, 539);
    disc.frames = Paths.getSparrowAtlas('maidUi/discChar');
    disc.animation.addByPrefix('disc', 'disc' + loadAnim, 24, true);
    disc.animation.play('disc');
    disc.scale.set(0.53, 0.53);
    disc.updateHitbox();
    disc.antialiasing = true;

    goldenDisc = new FlxSprite(1103.5, 533);
    goldenDisc.frames = Paths.getSparrowAtlas('maidUi/goldDisc');
    goldenDisc.animation.addByPrefix('disc', 'hudGold', 24, true);
    goldenDisc.animation.play('disc');
    goldenDisc.scale.set(0.53, 0.53);
    goldenDisc.updateHitbox();
    goldenDisc.antialiasing = true;
    goldenDisc.alpha = 0;

    bar = new FlxBar(872.5, 622, RIGHT_TO_LEFT, 300, 16, this, 'display', min, max);
    bar.angle = 3.5;
    bar.antialiasing = true;
    bar.createFilledBar(FlxColor.WHITE, barColor);

    iconP1 = new HealthIcon(player1, true);
    iconP1.y = score.y - 10;
    iconP1.x = score.x + 285;
    iconP1.updateHitbox();

    txt = new FlxText(915, 688, FlxG.width, "");
		txt.setFormat(Paths.font('scoreFont.ttf'), 24, FlxColor.WHITE, LEFT);
    txt.updateHitbox();
    txt.antialiasing = true;
    txt.angle = 4.2;

    for(i in 0...4){
      var _pt:FlxSprite = new FlxSprite(i * 30,i * 2);
      _pt.frames = Paths.getSparrowAtlas('maidUi/plus');
      _pt.animation.addByPrefix("idle","circle", 30, false);
      _pt.animation.play("idle");
      _pt.setGraphicSize(25,25);
      _pt.antialiasing = true;
      _pt.alpha = 0;
      plusGrp.add(_pt);
    }
    plusGrp.setPosition(700, 260);
    CoolUtil.getSound(Paths.sound("combo"));
    tmrCombo = new FlxTimer().start(1, function(tmr){});

    accSpr = new FlxSprite(4, 568);
    accSpr.frames = Paths.getSparrowAtlas('maidUi/results');
    for(i in 0...rank.length){accSpr.animation.addByPrefix(rank[i], rank[i] + '0', 24, false);}
    accSpr.scale.set(0.2, 0.2);
    accSpr.updateHitbox();
    accSpr.antialiasing = true;
    accSpr.scrollFactor.set();

    scoreGrp.add(disc);
    scoreGrp.add(goldenDisc);
    scoreGrp.add(bar);
    scoreGrp.add(score);
    scoreGrp.add(iconP1);
    scoreGrp.add(txt);
    scoreGrp.add(plusGrp);
    accGrp.add(acc);
    accGrp.add(accSpr);

    add(accGrp);
    add(scoreGrp);
  }
  public function setIcons(?player1){
    player1=player1==null?iconP1.animation.curAnim.name:player1;
    iconP1.changeCharacter(player1);
  }

  public function setColors(baseColor:FlxColor){
    txt.color = baseColor;
    bar.createFilledBar(FlxColor.WHITE, baseColor);
  }

  public function plusCombo():Void {
    if(!canPoint){return;}

    tempCombo++;

    if(tmrCombo != null){tmrCombo.active = false;}
    tmrCombo = new FlxTimer().start(((Conductor.stepCrochet / 1000)*16), function(tmr){tempCombo = 0;});

    if(tempCombo >= 16){
      tempCombo = 0;
      pointCombo++;

      var _curPoint:FlxSprite = plusGrp.members[plusGrp.members.length - (pointCombo-1)];
      if(_curPoint != null){
        _curPoint.alpha = 1;
        _curPoint.animation.play("idle", true);
        FlxG.sound.play(CoolUtil.getSound(Paths.sound("combo")));
        if(pointCombo == 5){FlxTween.tween(goldenDisc, {alpha: 1}, 1); cast(instance,PlayState).burst = true;}
      }      
    }
  }

  var lerpScore:Int = 0;
  var curScore:Int = 0;
  public function setScore(score:Int, grade:String){
    var anim:String = 'FC';
    switch (grade){
      case '☆☆☆☆' | "☆☆☆" | "": 
        anim = 'S+';
      case "☆" | "☆☆":
        anim = 'S+';
      default:
        anim = grade;
    }
    curScore = score;
    accSpr.animation.play(anim);
  }
  public function setIconSize(iconP1Size:Int){
    iconP1.setGraphicSize(Std.int(iconP1Size));

    iconP1.updateHitbox();
  }

  public function setGradeSize(gradeSize:Int){
    accSpr.setGraphicSize(Std.int(gradeSize));

    accSpr.updateHitbox();
  }

  public function beatHit(curBeat:Float){
    setIconSize(Std.int(iconP1.width+15));
    setGradeSize(Std.int(accSpr.width+15));
    acc.animation.play('acc');
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
    setIconSize(Std.int(FlxMath.lerp(iconP1.width, 140, Main.adjustFPS(0.1))));
    setGradeSize(Std.int(FlxMath.lerp(accSpr.width, 110, Main.adjustFPS(0.1))));
    var iconOffset:Int = 26;

    if (percent < 20 && iconP1.lossIndex!=-1)
      iconP1.animation.curAnim.curFrame = iconP1.lossIndex;
    else if(percent > 80 && iconP1.winningIndex!=-1)
      iconP1.animation.curAnim.curFrame = iconP1.winningIndex;
    else
      iconP1.animation.curAnim.curFrame = iconP1.neutralIndex;

    /*if (FlxG.keys.justPressed.UP) {
      txt.angle += 0.1;
      trace(txt.angle);
    }
    if (FlxG.keys.justPressed.DOWN) {
      txt.angle -= 0.1;
      trace(txt.angle);
    }*/
    
    lerpScore = Std.int(FlxMath.lerp(lerpScore, curScore, 0.1));

    /*if(FlxG.mouse.pressed){
      txt.setPosition(FlxG.mouse.x, FlxG.mouse.y);
      trace(txt.x + ' ' + txt.y);
    }*/

    super.update(elapsed);
    
    txt.text =  Std.string(lerpScore);
  }
}
