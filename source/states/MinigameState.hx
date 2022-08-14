package states;

import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import ui.*;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxExtendedSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import ui.*;
import lime.utils.Assets;
import openfl.display.StageQuality;
import ui.MiniGameObjects.Dragon;
import openfl.Lib;
import CoinBar;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class MinigameState extends MusicBeatState
{
    var achievement:MaidAchievement;
    var titleOp:Array<String> = ['play', 'exit'];
    var score:Int = 0;
    public static var click:Bool = true;
    public static var randomSpawn:Int;
     var tumami:MiniGameObjects;
    public static var spawnX:Array<Int> = [-78, 1066, 1258, -223, 507, 504, -213, 1287];
    public static var spawnY:Array<Int> = [484, 509, -254, -305, 630, -287, 121, 139];
    var moveX:Array<Int> = [474, -71, 1086, -77, 1083, 1083, -71];
    var moveY:Array<Int> = [-153, -153, -153, -152, 152, 480, 461];
    //Voy a borrar estas variables despues :P
    var randomMove:Int;
    public static var shoot:Int = 10;
    var shootText:FlxText;
    var titleState:Bool = true;
    var fontPixel = Paths.font("8-bit-hud.ttf");
    var curSelected:Int = 0;
    var defCam:FlxCamera;
    var camHud:FlxCamera;
    var gold:Bool = false;
    public static var camGame:FlxCamera;
   public static var ready:FlxSprite;
   public static var rounds:Int = 3;
    public static var end:Bool = false;
    public static var miniState:Bool = false;

    var animationName:Int = 10;

    override public function create()
    {
        super.create();

        Lib.current.stage.window.title = TitleState.title + ' - Dragon Hunt Minigame';

        rounds = 3;
        end = false;
        click = true;
        shoot = 10;

        defCam = new FlxCamera();

        camGame= new FlxCamera();
		camGame.bgColor.alpha = 0;

        camHud = new FlxCamera();
		camHud.bgColor.alpha = 0;
        

        FlxG.cameras.reset(defCam);

        FlxG.cameras.add(camGame);
        FlxG.cameras.add(camHud);
        FlxCamera.defaultCameras = [defCam];

        camHud.zoom = 1;
        camGame.zoom = 2.8;

        tumami = new MiniGameObjects();
        add(tumami);
        TitleState.playSong = true;
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Dragon Hunt Minigame" + ' - Score: ' + score + ' - Round: ' + rounds, null);
		#end

        FlxG.sound.playMusic(Paths.music('miniDragon'), 0.5);

        randomSpawn = Std.random(8);
        randomMove = Std.random(7);

        //MINIDRAGON!!!!
        tumami.loadLevel(1);
     
        
        add(tumami.medueleelpilin.get("capa1"));

        tumami.sprGrpId['menuItems'].cameras = [camHud];
        tumami.sprID['go'].cameras = [camHud];
        tumami.sprID['ready'].cameras = [camHud];
        tumami.sprID['barHud'].cameras = [camHud];
        tumami.sprID['dragonHud'].cameras = [camHud];
        tumami.sprID['title'].cameras = [camHud];
        tumami.sprID['mouse'].cameras = [camHud];
        tumami.txtID['shootText'].cameras = [camHud];
        tumami.txtID['scoreText'].cameras = [camHud];
        tumami.txtID['pointText'].cameras = [camHud];
        tumami.txtID['roundText'].cameras = [camHud];
        tumami.txtID['bestScoreText'].cameras = [camHud];
        tumami.txtID['axisText'].cameras = [camHud];

        FlxG.mouse.visible = false;

        click = false;
 
        changeItem();

        if (!FlxG.save.data.goldDragon){
            achievement = new MaidAchievement(1280, 527, 6);
            add(achievement);
        }
    }

    function eventAchi(){
        FlxG.save.data.goldDragon = true;
		FlxG.sound.play(Paths.sound('achievement'));
			
		FlxTween.tween(achievement, {x: achievement.x - 540}, 1, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween){
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxTween.tween(achievement, {x: achievement.x + 542}, 0.7, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween){
					achievement.kill();
                    //Si no se va a usar despues entonces destruyelo
				}});
			});
		}});
	}

    function readyGo()
	{
        click = false;

        tumami.sprID['ready'].alpha = 1;

        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            tumami.sprID['ready'].alpha = 0;
            tumami.sprID['set'].alpha = 1;
            FlxFlicker.flicker(tumami.sprID['set'], 1.5, 0.1, false, false, function(flick:FlxFlicker)
            {
                tumami.sprID['set'].alpha = 0;
                tumami.sprID['go'].alpha = 1;

                FlxTween.tween( tumami.sprID['go'], {alpha: 0}, 1, {ease:FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
                    click = true;
                    //tumami.dragon.dragonMove(randomMove);
                    tumami.dragon.checkOffset(randomMove);

                }});
            });
        });
    }

    function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= tumami.sprGrpId['menuItems'].length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = tumami.sprGrpId['menuItems'].length - 1;
		
		tumami.sprGrpId['menuItems'].forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
			}
			spr.updateHitbox();
		});
    }

    var shootCount:Int = 10;
    var sound:Bool;
    var daScore:String = '';
    var coinEvent:Bool = false;

    function daEnd()
    {
        if (score > FlxG.save.data.bestScore)
            FlxG.save.data.bestScore = score;
        else
            TitleState.bestScore = TitleState.bestScore;

        if (score == 3000)
        {
            daScore = 'perfect';
            CoinBar.addCoins(1000);
        }
        else if (score < 3000 && score >= 2000)
        {
            daScore = 'great';
            CoinBar.addCoins(500);
        }
        else if (score < 2000 && score >= 1000)
        {
            daScore = 'good';
            CoinBar.addCoins(100);
            score = 0;
        }
        else if (score < 1000 && score >= 500)
        {
            daScore = 'bad';
            CoinBar.addCoins(10);
        }
        else if (score < 500)
        {
            daScore = 'shit';
            CoinBar.deletCoins(50);
        }
        if (score > 3000)
        {
            daScore = 'perfect';
            CoinBar.addCoins(3000);
        }

        coinEvent = true;

        var coolScore:FlxSprite = new FlxSprite(0, 80).loadGraphic(Paths.image('miniDragon/hud/' + daScore));
        coolScore.screenCenter(X);
        coolScore.scale.set(1.3, 1.3);
        add(coolScore);

        new FlxTimer().start(2, function(tmr:FlxTimer)
        {
            if (miniState)
                FlxG.switchState(new MiniselecState());
            else
                FlxG.switchState(new MainMenuState());
        });
    }
    var cheating:Bool = false;
    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.ESCAPE)
        {
            if (miniState)
                FlxG.switchState(new MiniselecState());
            else
                FlxG.switchState(new MainMenuState());
        }

        tumami.txtID['shootText'].text = '' + shoot;
        if(!end)
            tumami.txtID['scoreText'].text = '' + score;
        tumami.txtID['roundText'].text = 'R=' + rounds;

        if (shoot == 0 && rounds == 0 || rounds == 0)
        {
            if (!coinEvent)
            {
                tumami.dragon.tween.active = false;
                click = false;
                end = true;

                daEnd();
            }
        }

        if (click)
        {
            #if desktop
            // Updating Discord Rich Presence
            DiscordClient.changePresence("Dragon Hunt Minigame" + ' - Score: ' + score + ' - Round: ' + rounds, null);
            #end

            if (!FlxG.mouse.overlaps( tumami.dragon))
            {
                if (FlxG.mouse.justPressed)
                {
                    shoot -= 1;
                    score -= 50;
        
                    if (score < 0)
                    {
                        score = 0;
                    }
                    
                    if(gold)
                    {
                        tumami.dragon.animation.play('mov');
                        gold = false;
                    }

                    tumami.txtID['pointText'].text = '-50';
                    tumami.txtID['pointText'].setPosition(tumami.sprID['mouse'].x, tumami.sprID['mouse'].y);
                    tumami.txtID['pointText'].alpha = 1;
                    FlxTween.tween(tumami.txtID['pointText'], {y:tumami.txtID['pointText'].y + 20, alpha: 0}, 0.3, {ease:FlxEase.expoInOut});
                
                    tumami.sprID['mouse'].animation.play('gun');
                    FlxG.sound.play(Paths.sound('maidShooting'));
                    FlxG.camera.flash(FlxColor.WHITE, 0.2);

                    if (shoot == 0 && rounds > 0)
                    {
                        rounds -= 1;
                      
                        
                        if (rounds >= 1)
                        {
                            shootCount = 10;
                            shoot = 10;
                            tumami.sprID['dragonHud'].animation.play('' + shootCount);
                        }
                
                        if ( tumami.dragon.tween.active)
                        {
                            tumami.dragon.tween.cancel();
                
                            click = false;
                            
                            tumami.dragon.animation.play('die');
                            FlxTween.tween( tumami.dragon, {y:  tumami.dragon.y + 1000}, 1.5, {ease:FlxEase.elasticInOut, onComplete: function(flxTween:FlxTween){
                                tumami.dragon.kill();

                                if (FlxG.random.bool(2)){
                                    tumami.dragon.animation.play('movgold');
                                    gold = true;
                                }
                                else
                                    tumami.dragon.animation.play('mov');

                                randomSpawn = Std.random(8);
                                    
                                new FlxTimer().start(0.5, function(tmr:FlxTimer)
                                {
                                    tumami.dragon.revive();
                
                                    tumami.dragon.setPosition(spawnX[randomSpawn], spawnY[randomSpawn]);
                
                                    tumami.dragon.revive();
                                    
                                    if (!end)
                                        readyGo();
                                });
                            }});
                        }    
                    }
                }
                else
                {
                    tumami.sprID['mouse'].animation.play('idle');
                }
            }
        }
        
        if (click)
        {
            #if desktop
            // Updating Discord Rich Presence
            DiscordClient.changePresence("Dragon Hunt Minigame" + ' - Score: ' + score + ' - Round: ' + rounds, null);
            #end

            if (FlxG.mouse.overlaps( tumami.dragon))
		    {
			    if (FlxG.mouse.justPressed)
			    {
                    if (gold)
                    {
                        score += 1000;

                        if(!FlxG.save.data.goldDragon) eventAchi();
                    }
                    else
                        score += 100;
                    
                    shoot -= 1;

                    FlxG.sound.play(Paths.sound('maidShooting'));
                    FlxG.camera.flash(FlxColor.WHITE, 0.2);

                    sound = true;
                    click = false;
                    tumami.dragon.tween.active = false;
                    shootCount -= 1;
                    randomSpawn = Std.random(8);
                    tumami.sprID['dragonHud'].animation.play('' + shootCount);
                    if(gold)
                    {
                        tumami.dragon.animation.play('diegold');
                        gold = false;
                    }
                    else
                        tumami.dragon.animation.play('die');
                    tumami.sprID['mouse'].animation.play('gun');
                    tumami.txtID['pointText'].text = '100';
                    tumami.txtID['pointText'].setPosition( tumami.dragon.x + 100,  tumami.dragon.y + 100);
                    tumami.txtID['pointText'].alpha = 1;

                    FlxTween.tween(tumami.txtID['pointText'], {y:tumami.txtID['pointText'].y + 20, alpha: 0}, 0.3, {ease:FlxEase.expoInOut});
                    tumami.dragon.tween.cancel();

                    FlxTween.tween( tumami.dragon, {y:  tumami.dragon.y + 1000}, 1.5, {ease:FlxEase.elasticInOut, onComplete: function(flxTween:FlxTween){

                        tumami.dragon.kill();

                        if  (shoot  == 0 && rounds > 0)
                        {
                            click = false;
                            rounds -= 1;

                            if (rounds >= 1)
                            {
                                shootCount = 10;
                                shoot = 10;
                                tumami.sprID['dragonHud'].animation.play('' + shootCount);
                            }

                            randomSpawn = Std.random(8);

                            new FlxTimer().start(0.5, function(tmr:FlxTimer)
                            {
                                tumami.dragon.revive();

                                if (FlxG.random.bool(2)){
                                    tumami.dragon.animation.play('movgold');
                                    gold = true;
                                }
                                else
                                    tumami.dragon.animation.play('mov');
                                tumami.dragon.setPosition(spawnX[randomSpawn], spawnY[randomSpawn]);

                                tumami.sprID['ready'].revive();

                                if (!end)
                                    readyGo();
                            });
                        }
                        else
                        {
                            new FlxTimer().start(0.5, function(tmr:FlxTimer)
                            {
                                tumami.dragon.revive();
        
                                tumami.dragon.setPosition(spawnX[randomSpawn], spawnY[randomSpawn]);
                                if (FlxG.random.bool(2)){
                                    tumami.dragon.animation.play('movgold');
                                    gold = true;
                                }
                                else
                                    tumami.dragon.animation.play('mov');
                                tumami.sprID['mouse'].animation.play('idle');
        
                                //tumami.dragon.dragonMove(randomMove);
                                tumami.dragon.checkOffset(randomMove);
                                
                                new FlxTimer().start(0.5, function(tmr:FlxTimer)
                                {       
                                    click = true;
                                });
                            });
                        }
                    }});
			    }
		    }
        }
        if (FlxG.keys.justPressed.M)
		{
			if (FlxG.mouse.visible)

				FlxG.mouse.visible = false;
			else
				FlxG.mouse.visible = true;
		}

        //axisText.text = 'X:' + roundText.x + 'Y:' + roundText.y;
        tumami.dragon.updateHitbox();

        tumami.sprID['mouse'].updateHitbox();

        tumami.sprID['mouse'].setPosition(FlxG.mouse.x - 40, FlxG.mouse.y - 60);

        if (titleState)
        {
            if (FlxG.keys.justPressed.UP)
                {
                    changeItem(-1);
                }
            if (FlxG.keys.justPressed.DOWN)
                {
                    changeItem(1);
                }
            if (FlxG.keys.justPressed.ENTER)
                {
                    var daChoice:String = titleOp[curSelected];

                    switch (daChoice)
					{
                        case 'play':
                            tumami.sprID['title'].kill();
                            tumami.sprGrpId['menuItems'].kill();
                            tumami.txtID['bestScoreText'].kill();
                            readyGo();
                            titleState = false;
                        case 'exit':
                            if (miniState){
                                TitleState.playSong = true;
                                FlxG.switchState(new MiniselecState());
                            }
                            else{
                                TitleState.playSong = true;
                                FlxG.switchState(new MainMenuState());
                            }
                    }
                }
        }

        if (!click)
        {
            if ( tumami.dragon.overlaps(tumami.sprID['arbustos']))
            {
                if (sound)
                {
                    FlxG.sound.play(Paths.sound('maidDie'));
                    sound = false;
                }
            }
        }
        super.update(elapsed);
    }
}