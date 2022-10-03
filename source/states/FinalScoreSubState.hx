package states;

#if desktop
import Discord.DiscordClient;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import ui.*;
import states.*;
import flixel.FlxCamera;

using StringTools;

class FinalScoreSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxSpriteGroup;
    var bg:FlxBackdrop;

    var frame1:FlxSprite;
    var frame2:FlxSprite;

    var overlay1:FlxSprite;
    var overlay2:FlxSprite;

    var resultSpr:FlxSprite;

    var counter:Int = 0;

    var btn:Array<String> = ['score', 'accuracy', 'sick'];
    var btnGrp:FlxSpriteGroup;

    var tween:FlxTween;
	var tween1:FlxTween;

    var timer:FlxTimer;

    var scoreOverlay:FlxSprite;

	var trans:MaidTransition;

	var txtGrp:FlxSpriteGroup;

	var scorex:Int = 0;
	var accuracyx:Float = 0;
	var sickx:Int = 0;
    var anim:String = '';

    public static var isStory:Bool = false;

	public function new(x:Float, y:Float, score:Int = 0, accuracy:Float, sick:Int, grade:String)
	{
		super();

        switch (grade){
            case "☆" | "☆☆" | '☆☆☆☆' | "☆☆☆" | "": 
              anim = 'S+';
            default:
              anim = grade;
        }

		scorex = score;
		accuracyx = accuracy;
		sickx = sick;

		trace(score);

		trans = new MaidTransition(0, 0);
		trans.screenCenter();

		bg = new FlxBackdrop(Paths.image('resultScore/bg'), 10, 0, true, false);
        bg.antialiasing = true;
		bg.velocity.set(-70, 0);
		add(bg);

        overlay1 = new FlxSprite().loadGraphic(Paths.image('resultScore/overlay1'));
        overlay1.antialiasing = true;
        add(overlay1);

        introHUD();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		add(trans);
	}

	function introHUD() {
        frame1 = new FlxSprite();
        frame1.frames = Paths.getSparrowAtlas('resultScore/overlayFrame');
        frame1.antialiasing = true;
        frame1.animation.addByPrefix('bg', 'bg', 35, false);
        frame1.animation.play('bg');
        add(frame1);

        btnGrp = new FlxSpriteGroup();
		txtGrp = new FlxSpriteGroup();

        for (i in 0...btn.length){
            var scor:FlxSprite = new FlxSprite();
            scor.frames = Paths.getSparrowAtlas('resultScore/scoreButtons');
            scor.antialiasing = true;
            scor.animation.addByPrefix('op', btn[i]);
            scor.animation.play('op');
            scor.updateHitbox();
            scor.alpha = 0;
            scor.ID = i;

			var txt = new FlxText(645, 255, FlxG.width, '', 25);
			txt.setFormat(Paths.font("scoreFont.ttf"), 25, FlxColor.WHITE, LEFT);
			txt.alpha = 0;

			switch(i){
                case 0:
					txt.setPosition(645, 255);
					txt.text = '' + scorex;
                    scor.setPosition(454, 233);
                case 1:
					txt.setPosition(790, 330);
					txt.text = '' + accuracyx + '%';
                    scor.setPosition(541, 307);
                case 2:
					txt.setPosition(605, 406);
					txt.text = '' + sickx;
                    scor.setPosition(454, 383);
            }
			
            btnGrp.add(scor);
			txtGrp.add(txt);
        }

        scoreOverlay = new FlxSprite(920, 90).loadGraphic(Paths.image('resultScore/scoreOverlay'));
        scoreOverlay.antialiasing = true;
        scoreOverlay.x += 500;
        add(scoreOverlay);

        resultSpr = new FlxSprite(scoreOverlay.x + 150, scoreOverlay.y + 42);
        resultSpr.frames = Paths.getSparrowAtlas('resultScore/results');
        resultSpr.animation.addByPrefix(anim, anim + '0');
        resultSpr.animation.play(anim);
        resultSpr.scale.set(0.35, 0.35);
        resultSpr.antialiasing = true;
        resultSpr.updateHitbox();

        add(btnGrp);
		add(txtGrp);
        add(resultSpr);

        intro(counter);
    }

    function skip() {
        FlxG.sound.play(Paths.sound('score3'));
        tween.cancel();
        timer.cancel();

        btnGrp.forEach(function(spr:FlxSprite)
        {
            spr.alpha = 1;
			txtGrp.members[spr.ID].alpha = 1;
            switch(spr.ID){
				case 0:
					txtGrp.members[spr.ID].setPosition(645, 255);
                    spr.setPosition(454, 233);
                case 1:
					txtGrp.members[spr.ID].setPosition(790, 330);
                    spr.setPosition(541, 307);
                case 2:
					txtGrp.members[spr.ID].setPosition(605, 406);
                    spr.setPosition(454, 383);
            }
        });    

		counter = 3;
		setResult();	 
    }

    function intro(curScore) {
        FlxG.sound.play(Paths.sound('score' + counter));
        btnGrp.members[curScore].y -= 10;
		txtGrp.members[curScore].y -= 10;
		tween = FlxTween.tween(txtGrp.members[counter], {y: txtGrp.members[curScore].y + 10, alpha: 1}, 0.5, {ease:FlxEase.expoInOut});
        tween = FlxTween.tween(btnGrp.members[counter], {y: btnGrp.members[curScore].y + 10, alpha: 1}, 0.5, {ease:FlxEase.expoInOut, onComplete:function (_) {
            if (counter <= 2){
                timer = new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    counter ++;
                    if (counter != 3) intro(counter);
                    else if (counter == 3){
                        setResult();
                    }
                });
            }
        }});
    }

    function setResult() {
		FlxG.sound.play(Paths.sound('score3'));
		counter ++;
        FlxTween.tween(resultSpr, {x: resultSpr.x - 500}, 1, {ease:FlxEase.expoInOut});
        FlxTween.tween(scoreOverlay, {x: scoreOverlay.x - 500}, 1, {ease:FlxEase.expoInOut, onComplete:function (_) {
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                 FlxG.sound.playMusic(Paths.music('finalScore'), 1);
            });
        }});
    }

    override function update(elapsed:Float)
    {

        if (FlxG.keys.justPressed.ENTER && counter <= 2){
            skip();
        }
		else if (FlxG.keys.justPressed.ENTER && counter == 4){
			FlxG.sound.play(Paths.sound('pressEnter'));
			FlxG.camera.fade(FlxColor.WHITE, 2, true, function() {
				FlxG.sound.playMusic(Paths.musicRandom('maidTheme', 1, 4), 1, true);

                if(!isStory) trans.transIn('free');
                else trans.transIn('main');
			});
		}

        super.update(elapsed);
    }

	override function destroy()
	{

		super.destroy();
	}

}
