package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import ui.*; 
import uuid.*;

using StringTools;
 

class DisclaimerState extends MusicBeatState
{

    var tohru:FlxSprite;
    var isStart:Bool = false;

	override function create()
	{	
        super.create();
        trace('ITS MAID TIME!');

        var uuid = FlxG.save.data.uuid;

        trace('uuid: ' + uuid);

        if(uuid == null)
        {
            uuid = Uuid.v4();

            var stringData = haxe.Json.stringify({
                username: "User",
                id: uuid,
                coins: 0,
                progress: 0,
                trophies: []
            }, "\t");

            var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/user");

            http.addHeader('Content-Type', 'application/json');
            http.setPostData(stringData);

            var response = "";
    
            http.onStatus = function(status) {
                if(status == 200)
                {
                    trace("Success!");
                    FlxG.save.data.uuid = uuid;
                }
                else
                {
                    trace("Error!");
                }
            }
    
            http.onData = function(data) {
                response = data;
            };

            http.request(true);

            trace(response);

        } else {
            var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/user/" + uuid);

            var jsonResponse;

            var response = "";
    
            http.onStatus = function(status) {
                if(status == 200)
                {
                    trace("Success!");
                }
                else
                {
                    trace("Error!");
                }
            }
    
            http.onData = function(data) {
                trace(data);
                jsonResponse = haxe.Json.parse(data);
            };

            http.request();

            trace(jsonResponse.username);
        }



        var disclaimer:FlxSprite = new FlxSprite(-20, 0).loadGraphic(Paths.image('maidMenu/disclaimer'));
        disclaimer.alpha = 0;

        var pressEnter:FlxSprite = new FlxSprite(0, 650).loadGraphic(Paths.image('maidMenu/press_enter'));
        pressEnter.alpha = 0;

        var tohru_frames = Paths.getSparrowAtlas('maidMenu/tohru_point');

		tohru = new FlxSprite(900 + 500, 410);
		tohru.frames = tohru_frames;
        tohru.scale.set(0.4, 0.4);
        tohru.updateHitbox();
		tohru.animation.addByPrefix('point', 'point', 7, true);
		
        add(disclaimer);
        add(pressEnter);
        add(tohru);

        FlxTween.tween(tohru, {x: tohru.x - 500}, 0.8, {ease: FlxEase.quadInOut, type: ONESHOT, onComplete: function(tween:FlxTween)
            {
                tohru.animation.play('point');
            }
        });	

        new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxTween.tween(disclaimer, {alpha: 1}, 2.0, {onComplete: function(tween:FlxTween)
                {
                    FlxTween.tween(pressEnter, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG});
                        isStart = true;
                }
            });

		});
	}

	override function update(elapsed:Float)
	{
        if(isStart)
        {
            if (FlxG.keys.justPressed.ENTER)
                FlxG.switchState(new LogoState());
        }
    
		
       super.update(elapsed);
	}
}