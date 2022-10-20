package ui;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class YankenObjects extends FlxTypedGroup<FlxBasic>
{
    public var layer:Map<String,FlxTypedGroup<FlxBasic>> = 
    [
        "layer1"=>new FlxTypedGroup<FlxBasic>(),
    ];
    public var sprID:Map<String, FlxSprite> = [];

    public var sprGrpId:Map<String,FlxTypedGroup<FlxSprite>> = [];

    public var bg:FlxSprite;
    public var idleHand:FlxSprite;
    public var point:FlxSprite;
    public var result:FlxSprite;
    public var daCoin:FlxSprite;

    public var grpHands:FlxTypedGroup<FlxSprite>;
    public var grpHand:FlxTypedGroup<FlxSprite>;
    public var pointGrp:FlxTypedGroup<FlxSprite>;

    public static var daHands:Array<String> = ['rock', 'paper', 'scissor'];
    public static var points = 3;

    public function new() 
    {
        super();
    }

    public function loadLevel(curLevel:Int = 1)
    {
        switch(curLevel)
        {
            case 1:
                bg = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('yankenPo/bg')));
                bg.setGraphicSize(1280, 720);
                bg.antialiasing = false;
                bg.screenCenter();
                bg.animation.play('bg');

                grpHand = new FlxTypedGroup<FlxSprite>();

                grpHands = new FlxTypedGroup<FlxSprite>();

                pointGrp = new FlxTypedGroup<FlxSprite>();

                for (i in 0...2)
                {
                    var point:FlxSprite = new FlxSprite();
                    point.frames = Paths.getSparrowAtlas('yankenPo/point');
                    point.animation.addByPrefix('0', 'point0', 24, false);
                    point.animation.addByPrefix('1', 'point1', 24, false);
                    point.animation.addByPrefix('2', 'point2', 24, false);
                    point.animation.addByPrefix('3', 'point3', 24, false);
                    point.animation.play('0');
                    point.setGraphicSize(Std.int(point.width * 7));
                    point.antialiasing = false;
                    point.updateHitbox();

                    pointGrp.add(point);
                    //idle hand
                    var hand:FlxSprite = new FlxSprite();
                    hand.frames = Paths.getSparrowAtlas('yankenPo/idleHand');
                    hand.animation.addByPrefix('shake', 'shake', 24, false);
                    hand.setGraphicSize(Std.int(hand.width * 8));
                    hand.updateHitbox();
                    hand.antialiasing = false;

                    if (i == 0)
                    {
                        hand.setPosition(125, 100);
                        point.setPosition(148, 512);
                    }
                    else 
                    {
                        hand.setPosition(822, 100);
                        point.setPosition(789, 512);
                        hand.flipX = true;
                    }

                    grpHand.add(hand);

                    //hands selected
                    for (a in 0...daHands.length)
                    {
                        var hands:FlxSprite = new FlxSprite();
                        hands.frames = Paths.getSparrowAtlas('yankenPo/hands');
                        hands.animation.addByPrefix('selected', daHands[a] + ' on', 24, false);
                        hands.animation.addByPrefix('fail','fail', 24, false);
                        hands.alpha = 0;
                        hands.animation.play('selected');
                        hands.setGraphicSize(Std.int(hands.width * 7.5));
                        hands.updateHitbox();
                        hands.antialiasing = false;

                        if (grpHands.length <= 2) 
                        {
                            switch(a)
                            {
                                case 0:
                                    hands.setGraphicSize(Std.int(hands.width / 1.3));
                                    hands.setPosition(185, 203);
                                case 1:
                                    hands.setPosition(220, 169);
                                case 2:
                                    hands.setPosition(220, 197);
                            }
                        }
                        else 
                        {
                            hands.flipX = true;
                            switch(a)
                            {
                                case 0:
                                    hands.setGraphicSize(Std.int(hands.width / 1.3));
                                    hands.setPosition(801, 203);
                                case 1:
                                    hands.setPosition(759, 169);
                                case 2:
                                    hands.setPosition(764, 197);
                            }
                        }

                        grpHands.add(hands);
                    }
                }

                result = new FlxSprite();
                result.frames = Paths.getSparrowAtlas('yankenPo/daResult');
                result.animation.addByPrefix('win', 'win', 24, false);
                result.animation.addByPrefix('lose', 'lose', 24, false);
                result.animation.addByPrefix('trie', 'trie', 24, false);
                result.updateHitbox();
                result.screenCenter();
                result.alpha = 0;

                daCoin = new FlxSprite();
                daCoin.frames = Paths.getSparrowAtlas('yankenPo/coinsResult');
                daCoin.animation.addByPrefix('win', 'winer', 24, false);
                daCoin.animation.addByPrefix('lose', 'loser', 24, false);
                daCoin.updateHitbox();
                daCoin.screenCenter();
                daCoin.alpha = 0;
   
                layer.get("layer1").add(bg);
                layer.get("layer1").add(grpHand);
                layer.get("layer1").add(grpHands);
                layer.get("layer1").add(pointGrp);
                layer.get("layer1").add(result);
                layer.get("layer1").add(daCoin);

                sprID['bg'] = bg;
                sprGrpId['hand'] = grpHand;
                sprGrpId['hands'] = grpHands;
                sprGrpId['point'] = pointGrp;
                sprID['result'] = result;
                sprID['coin'] = daCoin;
        
         }
    }

    var daObject:Int = 0;
    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.A)
        {
          daObject ++;
          if (daObject >= 6)
              daObject = 0;
        }

        if (FlxG.mouse.pressed)
        {
          switch (daObject)
          {
              case 3:
                grpHands.members[0].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                  trace(grpHands.members[0].x + ' ' + grpHands.members[0].y);
              case 4:
                grpHands.members[1].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                  trace(grpHands.members[1].x + ' ' + grpHands.members[1].y);
              case 5:
                grpHands.members[2].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                  trace(grpHands.members[2].x + ' ' + grpHands.members[2].y);
          }
        }
        super.update(elapsed);   
    }
}