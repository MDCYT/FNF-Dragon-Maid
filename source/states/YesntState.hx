package states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxExtendedSprite;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import interfaz.*;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import lime.utils.Assets;
 
#if desktop
import Discord.DiscordClient;
#end
   
using StringTools;

class YesntState extends MusicBeatState
{
    override public function create()
    {
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Te Amo Yesnt", null);
		#end

        FlxG.sound.playMusic(Paths.music('duck'), 1);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('cuack'));
        add(bg);

        super.create();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new MainMenuState());
        }
    }
          
}