package states;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.input.gamepad.FlxGamepad;
import flixel.system.ui.FlxSoundTray;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.FlxSprite;
import io.newgrounds.NG;
import flixel.FlxState;
import openfl.Assets;
import flixel.FlxG;
import openfl.Lib;
import haxe.Timer;
import Options;
import ui.*;

using StringTools;

class NESState extends MusicBeatState {
    private var _characters:FlxTypedGroup<NESCharacter>;
    private var _bullets:FlxTypedGroup<NESShoot>;

    private var spawn_timer:Timer;

	override public function create():Void {
		super.create();

        var bg1 = new FlxBackdrop(Paths.image('miniGame/Sky'), 10, 0, true, false);
		bg1.velocity.set(-30, 0);
		add(bg1);

        var bg2 = new FlxBackdrop(Paths.image('miniGame/Mountains'), 10, 0, true, false);
		bg2.velocity.set(-50, 0);
		add(bg2);

        var bg3 = new FlxBackdrop(Paths.image('miniGame/Floors'), 10, 0, true, false);
		bg3.velocity.set(-60, 0);
		add(bg3);

        spawn_timer = new Timer(1500);
        spawn_timer.run = function(){
            if(FlxG.random.bool(40)){_characters.add(new NESCharacter(FlxG.width+10,FlxG.random.float(50,FlxG.height-50),"Blue",cast _characters,cast _bullets));}
            if(FlxG.random.bool(20)){_characters.add(new NESCharacter(FlxG.width+10,FlxG.random.float(50,FlxG.height-50),"Red",cast _characters,cast _bullets));}
            if(FlxG.random.bool(0.1)){_characters.add(new NESCharacter(FlxG.width+10,FlxG.random.float(50,FlxG.height-50),"Gold",cast _characters,cast _bullets));}
        }

        _characters = new FlxTypedGroup<NESCharacter>();
        _bullets = new FlxTypedGroup<NESShoot>();
       
        _characters.add(new NESCharacter(100,100,"Player",cast _characters,cast _bullets,controls));
        
        add(_bullets);
        add(_characters);

        reScale(2);
	}

	override function update(elapsed:Float){
		super.update(elapsed);

	}

	override function beatHit(){
		super.beatHit();
	}
    
    public function reScale(_scale:Float, ?grp:FlxGroup){
        if(grp == null){grp = this;}

        for(i in grp.members){
            if((i is FlxSprite)){(cast(i, FlxSprite)).scale.set(_scale,_scale); continue;}
            if((i is FlxTypedGroup) || (i is FlxGroup)){reScale(_scale, cast i); continue;}
        }
    }
}

class NESCharacter extends FlxSprite {
    private var rec_bullets:FlxTypedGroup<NESShoot> = new FlxTypedGroup<NESShoot>();

    public static final infoChar:Map<Dynamic, Float> = [
        'inmunity' => 3,
        'maxVel' => 300,
        'acc' => 3000
    ];

    public var targets:FlxGroup;
    public var bullets:FlxGroup;

    public var controls:Controls;

    public var inmunity:Bool = false;
    public var type:String = "";
    public var health_points:Int = 5;
    public var onDeath:Void->Void = function(){};

    public function new(X:Float, Y:Float, _type:String, _targets:FlxGroup, _bullets:FlxGroup, _controls:Controls = null){
        this.controls = _controls;
        this.targets = _targets;
        this.bullets = _bullets;
        this.type = _type;
        super(X,Y);

        rec_bullets.add(new NESShoot());

        this.maxVelocity.set(infoChar['maxVel'],infoChar['maxVel']);
        this.drag.set(infoChar['acc'],infoChar['acc']);

        loadChar(type);
    }

    public var lastAnim:String = "";
    public function loadChar(_type:String):Void {
        if(this.animation.curAnim != null){lastAnim = this.animation.curAnim.name;}else{lastAnim = "idle";}

        switch(type){
            default:{
                frames = Paths.getSparrowAtlas('miniGame/tohru');
                animation.addByPrefix('idle','fly', 12, true);
                animation.addByPrefix('shoot','fire', 12, false);
            }
            case "Blue":{
                frames = Paths.getSparrowAtlas('miniGame/enemies');
                animation.addByPrefix('idle','blue', 12, true);
                scale.add(1, 1);
                acceleration.x = -300;

                type = "Enemy";
                health_points = 1;
            }
            case "Red":{
                frames = Paths.getSparrowAtlas('miniGame/enemies');
                animation.addByPrefix('idle','red', 12, true);

                acceleration.x = -200;

                type = "Enemy";                
                health_points = 2;
            }
            case "Gold":{
                frames = Paths.getSparrowAtlas('miniGame/enemies');
                animation.addByPrefix('idle','gold', 12, true);

                acceleration.x = -500;
                
                type = "Enemy";                
                health_points = 3;
            }
        }

        animation.play(lastAnim);
        updateHitbox();
    }

	override function update(elapsed:Float):Void{
		super.update(elapsed);

        if(type == "Player"){
            if(this.animation.finished && this.animation != null && this.animation.curAnim != null && this.animation.curAnim.name == "shoot"){animation.play('idle');}

            keyShit();

            if(FlxG.overlap(this, targets)){
                for(t in targets){
                    if(t != this && FlxG.overlap(this, t)){
                        checkHit();
                    }
                }
            }
        }
    }

    public function keyShit():Void {

        if(FlxG.keys.justPressed.SPACE){shoot();}

        if(FlxG.keys.pressed.LEFT && !FlxG.keys.pressed.RIGHT){
            this.acceleration.x = -infoChar['acc'];
        }else if(FlxG.keys.pressed.RIGHT && !FlxG.keys.pressed.LEFT){
            this.acceleration.x = infoChar['acc'];
        }else{
            this.acceleration.x = 0;
        }

        if(FlxG.keys.pressed.UP && !FlxG.keys.pressed.DOWN){
            this.acceleration.y = -infoChar['acc'];
        }else if(FlxG.keys.pressed.DOWN && !FlxG.keys.pressed.UP){
            this.acceleration.y = infoChar['acc'];
        }else{
            this.acceleration.y = 0;
        }
    }

    public function shoot():Void {
        animation.play("shoot", true);

        var _bullet:NESShoot = rec_bullets.recycle(NESShoot);
        _bullet.setPosition(this.getGraphicMidpoint().x, this.getGraphicMidpoint().y);
        _bullet.shooter = this;
        _bullet.targets = targets;
        _bullet.flipX = this.flipX;
        _bullet.velocity.x = _bullet.flipX ? -1000 : 1000;
        bullets.add(_bullet);
    }

    public function checkHit():Void {
        if(inmunity){return;}

        health_points--;

        if(type == "Player"){
            inmunity = true;
            var _tim:Timer = new Timer(250);
            _tim.run = function(){this.alpha = this.alpha >= 1 ? 0 : 1 ;};
            new FlxTimer().start(infoChar['inmunity'], function(tmr:FlxTimer){this.alpha = 1; inmunity = false; _tim.stop();});
        }

        if(health_points <= 0){this.kill(); this.destroy();}
        onDeath();
    }
}

class NESShoot extends FlxSprite {
    public var shooter:NESCharacter;
    public var targets:FlxGroup;

    public function new(){
        super();
        loadGraphic(Paths.image("miniGame/fuego"));
    }

    override function update(elapsed:Float):Void{
		super.update(elapsed);

        if(!this.isOnScreen()){this.kill();}

        if(!FlxG.overlap(this, targets)){return;}
        for(t in targets){
            if(t != shooter && FlxG.overlap(this, t)){
                this.kill();
                if((t is NESCharacter)){(cast(t, NESCharacter)).checkHit();}
            }
        }
    }
}
