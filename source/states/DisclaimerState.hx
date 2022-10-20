package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.app.Application;
import ui.*; 
import uuid.*;

using StringTools;
 
typedef UserData = {
    username: String,
    id: String,
    coins: Int,
    progress: Int,
    trophies: Array<Any>,
    avatar: String,
    createdAt: Date,
    updatedAt: Date,
};
class DisclaimerState extends MusicBeatState
{

    var tohru:FlxSprite;
    var isStart:Bool = false;
    var cartel:Warning;
    var inWarn:Bool = false;
    var loading:FlxSprite;

	override function create()
	{	
        super.create();
        trace('ITS MAID TIME!');

        cartel = new Warning(0, 0, false, true);
		cartel.antialiasing = true;

        loading = new FlxSprite();
        loading.frames = Paths.getSparrowAtlas('maidMenu/loading');
        loading.animation.addByPrefix('load', 'Loadin_shit');
        loading.antialiasing = true;
        loading.screenCenter();
        loading.animation.play('load');
        loading.alpha = 0;
        

        add(loading);
        add(cartel);

        loadFalse();
	}

    function initState() {
        var disclaimer:FlxSprite = new FlxSprite(-20, 0).loadGraphic(CoolUtil.getBitmap(Paths.image('maidMenu/disclaimer')));
        disclaimer.alpha = 0;

        var pressEnter:FlxSprite = new FlxSprite(0, 650).loadGraphic(CoolUtil.getBitmap(Paths.image('maidMenu/press_enter')));
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

    function loadFalse() {
        loading.alpha = 1;

        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            loading.alpha = 0;
            checkInternet();
        });
    }

    function checkInternet() {
        var uuid = FlxG.save.data.uuid;

        trace('uuid: ' + uuid);

        if(uuid == null)
        {
            uuid = Uuid.v4();

            var coins = FlxG.save.data.coin;
            if(FlxG.save.data.coin == null) coins = 0;

            var progress = FlxG.save.data.progress;
            if(FlxG.save.data.progress == null) progress = 0;

            var trophies = FlxG.save.data.trophies;
            if(FlxG.save.data.trophies == null) trophies = [];

            var stringData = haxe.Json.stringify({
                username: "User",
                id: uuid,
                "coins": coins,
                "progress": progress,
                "trophies": trophies,
                "avatar": "https://expressjs-production-4733.up.railway.app/img/avatars/bf.png",
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
                    initState();
                }
                else
                {
                    createWarn();
                    trace("Error!");
                }
            }

            http.onError = function(status) {
                createWarn();
                trace("Error!");
            };
    
            http.onData = function(data) {
                response = data;
            };

            http.request(true);

        } else {
            var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/user/" + uuid);

            var jsonResponse:UserData;
    
            http.onStatus = function(status) {
                if(status == 200)
                {
                    trace("Success!");
                }
                else
                {
                    createWarn();
                    trace("Error!");
                }
            }

            http.onError = function(status) {
                createWarn();
                trace("Error!");
            };
    
            http.onData = function(data) {
                jsonResponse = haxe.Json.parse(data);

                var coins = FlxG.save.data.coin;

                if(jsonResponse.coins < FlxG.save.data.coin)
                {
                    coins = FlxG.save.data.coin;
                } else {
                    coins = jsonResponse.coins;
                } 

                var username;
                if(jsonResponse.username != FlxG.save.data.user)
                {
                    username = FlxG.save.data.user;
                } else {
                    username = jsonResponse.username;
                }

                var progress;
                if(jsonResponse.progress < FlxG.save.data.progress)
                {
                    progress = FlxG.save.data.progress;
                } else {
                    progress = jsonResponse.progress;
                }

                var trophies;
                if(!FlxG.save.data.trophies) {
                    trophies = jsonResponse.trophies;
                } else {
                    if(jsonResponse.trophies.length < FlxG.save.data.trophies.length)
                    {
                        trophies = FlxG.save.data.trophies;
                    } else {
                        trophies = jsonResponse.trophies;
                    }
                }

                var avatar = FlxG.save.data.userTheme;
                switch(FlxG.save.data.userTheme){
                    case 0:
                        avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/bf.png";
                    case 1:
                        avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/gf.png";
                    case 2:
                        avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/elma.png";
                    default:
                        avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/bf.png";
                }

                var stringData = haxe.Json.stringify({
                    username: username,
                    id: uuid,
                    coins: coins,
                    progress: progress,
                    trophies: trophies,
                    avatar: avatar
                }, "\t");

                var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/user/update/" + uuid);

                http.addHeader('Content-Type', 'application/json');
                http.setPostData(stringData);

                http.onStatus = function(status) {
                    if(status == 200)
                    {
                        initState();
                        trace("Success!");
                    }
                    else
                    {
                        createWarn();
                        inWarn = true;
                        trace("Error!");
                    }
                }

                http.onError = function(status) {
                    createWarn();
                    trace("Error!");
                };

                http.onData = function(data) {
                    trace(data);
                }

                http.request(true);
            };

            http.request();
        }
    }

    function createWarn() {
        if(!inWarn) cartel.setWarn(1, 'warning', null, 2);
        cartel.popUp();
        inWarn = true;
    }

	override function update(elapsed:Float)
	{
        if(isStart)
        {
            if (FlxG.keys.justPressed.ENTER)
                FlxG.switchState(new LogoState());
        }

        if (inWarn){
            if (FlxG.keys.justPressed.ENTER){
                switch(cartel.btn.curSelected){
                    case 0:
                        FlxG.sound.play(Paths.sound('ann'));
                        cartel.popOut();
                        loadFalse();
                    case 1:
                        FlxG.sound.play(Paths.sound('ann'));
                        cartel.popOut();
                        initState();
                        inWarn = false;
                }
            }
        }
    
		
       super.update(elapsed);
	}
}