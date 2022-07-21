package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;
 
class LogoState extends MusicBeatState
{
    
    var logo:FlxSprite;
    var tween:FlxTween;
    var whiteWall:FlxSprite;
 
    override function create()
    {
        super.create();
        whiteWall = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
        whiteWall.alpha = 0;

        add(whiteWall);

        FlxTween.tween(whiteWall, {alpha: 1}, 0.2);
        logoIntro(0);

    }
    
    var end:Bool = true;
    var art:Int = 0;

    function logoIntro(daLogo:Int = 0)
    {
        art += 1;
        if (daLogo < 3)
        {
            logo = new FlxSprite().loadGraphic(Paths.image('logo' + daLogo));
            logo.screenCenter();
            logo.antialiasing = true;
            logo.alpha = 0;
            add(logo);
            tween = FlxTween.tween(logo, {alpha: 1}, 2, {onComplete: function(twn:FlxTween) {
                new FlxTimer().start(1.5, function(tmr:FlxTimer)
                {
                    tween = FlxTween.tween(logo, {alpha: 0}, 2, {onComplete: function(twn:FlxTween) {
                        logoIntro(art);
                    }});
                });        
            }});
        }
        else
        {
            end = false;
            tween.cancel();
            FlxG.camera.fade(FlxColor.BLACK, 1, false, function () {
                FlxG.switchState(new TitleState());
            });
        }
    }
    override function update(elapsed:Float)
    {
        if (end)
        {
            if (FlxG.keys.justPressed.ENTER)
            {
                end = false;
                FlxG.camera.fade(FlxColor.BLACK, 1, false, function () {
                    FlxG.switchState(new TitleState());
                });
            }
        }
        super.update(elapsed);
    }
}