package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;

using StringTools;

class YankenState extends MusicBeatState
{
    var state1:YankenObjects;
    var state2:YankenBar;
    var bg:FlxSprite;
    var hand:Int = 0;
    var selec:Int = 0;
    var selected:Bool = false;
    var p1P:Int = 0;
    var cpuP:Int = 0;
    var timer:Float = 1.4;

    override public function create()
    {
        super.create();

        FlxG.mouse.visible = true;

        state1 = new YankenObjects();
        add(state1);

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;

        state2 = new YankenBar(0, 0);
        state2.alpha = 0;

        state1.loadLevel(1);

        add(state1.layer.get("layer1"));
        add(state2);

        shakeHand();

    }

    var daShake:Int = -1;

    function shakeHand()
    {
        if (p1P >= 3 || cpuP >= 3)
        {
            trace('win');
            p1P = 0;
            cpuP = 0;

            state1.sprGrpId['point'].forEach(function(spr:FlxSprite){
                spr.animation.play('0');
            });
        }

        daShake ++;
        state1.sprGrpId['hand'].forEach(function(spr:FlxSprite){
            spr.animation.play('shake');
            spr.animation.finishCallback = function(_){
                spr.animation.play('shake');
                spr.animation.finishCallback = function(_){
                    daShake = -1;
                    selecOp();
                }
            }
        });    
    }

    function selecOp()
    {
        FlxTween.tween(state2, {alpha: 1}, 0.4, {onComplete: function(twn:FlxTween){
            state2.drown = true;
            selected = true;
        }});
    }   

    function yesSelec(cpu:Int, p1:Int )
    {
        state2.drown = false;
        selected = false;
        FlxTween.tween(state2, {alpha: 0}, 0.4, {onComplete: function(twn:FlxTween){

            state2.time = 1;
            state1.sprGrpId['hand'].members[1].alpha = 0;
            state1.sprGrpId['hand'].members[0].alpha = 0;
            state1.sprGrpId['hands'].members[cpu].alpha = 1;
            state1.sprGrpId['hands'].members[selec + 3].alpha = 1;
            result(cpu, p1);

            new FlxTimer().start(1.3, function(tmr:FlxTimer)
            {
                state1.sprGrpId['hand'].members[1].alpha = 1;
                state1.sprGrpId['hand'].members[0].alpha = 1;
                state1.sprGrpId['hands'].members[cpu].alpha = 0;
                state1.sprGrpId['hands'].members[selec + 3].alpha = 0;
            });
            
        }});
    }

    function anResult(daAnimation:String) {
        
        FlxTween.tween(state1.sprID['result'], {alpha: 1}, 0.3, {ease: FlxEase.expoInOut});

        state1.sprID['result'].animation.play(daAnimation);
        state1.sprID['result'].updateHitbox();
        state1.sprID['result'].screenCenter();
        state1.sprID['result'].animation.finishCallback = function (_){
            FlxTween.tween(state1.sprID['result'], {alpha: 0}, 0.3, {onComplete: function (twn:FlxTween){
                if (p1P == 3)
                {
                    state1.sprID['coin'].alpha = 1;
                    state1.sprID['coin'].animation.play('win');
                    FlxG.save.data.coin += 300;
                    timer = 2;
                }
                else if (cpuP == 3)
                {
                    state1.sprID['coin'].alpha = 1;
                    state1.sprID['coin'].animation.play('lose');
                    FlxG.save.data.coin -= 100;
                    timer = 2;
                }
                else timer = 1.2;
                new FlxTimer().start(timer, function(tmr:FlxTimer)
                {
                    state1.sprID['coin'].alpha = 0;
                    shakeHand();
                });
            }});
        }
    }

    function result(cpu:Int, p1:Int)
    {
        var curCPU:String = YankenObjects.daHands[cpu];
        var curP1:String = YankenObjects.daHands[p1];

        if (cpu == p1 || p1 == cpu)
        {
            trace('trie');
            anResult('trie');
        }
        else
        {
            if (curP1 == 'rock')
            {
                switch (curCPU)
                {
                    case 'paper':
                        cpuP += 1;
                        state1.sprGrpId['point'].members[0].animation.play('' + cpuP);
                        anResult('lose');
                        trace('lose');
                    case 'scissor':
                        p1P += 1;
                        state1.sprGrpId['point'].members[1].animation.play('' + p1P);
                        anResult('win');
                }
            }
            else if (curP1 == 'paper')
            {
                switch (curCPU)
                {
                    case 'scissor':
                        cpuP += 1;
                        state1.sprGrpId['point'].members[0].animation.play('' + cpuP);
                        trace('lose');
                        anResult('lose');
                    case 'rock':
                        p1P += 1;
                        state1.sprGrpId['point'].members[1].animation.play('' + p1P);
                        trace('win');
                        anResult('win');
                }
            }
            else if (curP1 == 'scissor')
            {
                switch (curCPU)
                {
                    case 'rock':
                        cpuP += 1;
                        state1.sprGrpId['point'].members[0].animation.play('' + cpuP);
                        trace('lose');
                        anResult('lose');
                    case 'paper':
                        p1P += 1;
                        state1.sprGrpId['point'].members[1].animation.play('' + p1P);
                        trace('win');
                        anResult('win');
                }
            }
        }

    }

    var daObject:Int = 0;
    override public function update(elapsed:Float)
    {

       /* if (FlxG.keys.justPressed.A)
        {
            daObject ++;
            if (daObject >= 6)
                daObject = 0;
        }
      
        if (FlxG.mouse.pressed)
        {
            switch (daObject)
            {
                case 0:
                    state1.sprGrpId['hands'].members[0].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                    trace(state1.sprGrpId['hands'].members[0].x + ' ' + state1.sprGrpId['hands'].members[0].y);
                case 1:
                    state1.sprGrpId['hands'].members[1].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                    trace(state1.sprGrpId['hands'].members[1].x + ' ' + state1.sprGrpId['hands'].members[1].y);
                case 2:
                    state1.sprGrpId['hands'].members[2].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                     trace(state1.sprGrpId['hands'].members[2].x + ' ' + state1.sprGrpId['hands'].members[2].y);
                case 3:
                    state1.sprGrpId['hands'].members[3].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                    trace(state1.sprGrpId['hands'].members[3].x + ' ' + state1.sprGrpId['hands'].members[3].y);
                case 4:
                    state1.sprGrpId['hands'].members[4].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                    trace(state1.sprGrpId['hands'].members[4].x + ' ' + state1.sprGrpId['hands'].members[4].y);
                case 5:
                    state1.sprGrpId['hands'].members[5].setPosition(FlxG.mouse.x, FlxG.mouse.y);
                     trace(state1.sprGrpId['hands'].members[5].x + ' ' + state1.sprGrpId['hands'].members[5].y);
            }
        }
        /*if (p1P >= 3 || cpuP >= 3)
        {
            trace('win');
            p1P = 0;
            cpuP = 0;

            state1.sprGrpId['point'].forEach(function(spr:FlxSprite){
                spr.animation.play('0');
            });
        }*/

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(new MainMenuState());
        
        if (selected)
        {
            state2.selecHands.forEach(function(spr:FlxSprite)
            {      
                if (FlxG.mouse.overlaps(spr))
                {
                    spr.updateHitbox();
                    spr.animation.play('selected');
                    if (FlxG.mouse.justPressed)
                    {
                        selec = hand;
                        yesSelec(Std.random(3), selec);
                    }
                }
                else{
                    spr.animation.play('idle');
                    spr.updateHitbox();
                }

                hand ++;

                if (hand >= 3)
                {
                    hand = 0;
                }
            });
        }

        if (state2.time <= 0){
            state2.time = 1;
            selec = Std.random(3);
            yesSelec(Std.random(3), selec);
        }
        super.update(elapsed);
    }
}