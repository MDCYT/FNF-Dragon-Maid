package states;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import openfl.filters.ShaderFilter;
import sys.io.File;
import flixel.group.FlxSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;
import Options;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;
import flash.events.MouseEvent;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxState;
import openfl.Lib;
import EngineData.WeekData;
import EngineData.SongData;
import haxe.Json;
import sys.io.File;
import openfl.Lib;
import flixel.system.FlxSound;
import openfl.media.Sound;
import ui.*;
#if cpp
import Sys;
import sys.FileSystem;
#end
import CoinBar;

using StringTools;

class CreditsState extends MusicBeatState
{
	var trans:MaidTransition;

    var iconsGrp:FlxTypedGroup<CreditsLogo>;

	override function create(){
		super.create();

        if (Lib.current.stage.window.borderless){
			Lib.current.stage.window.borderless = false;
		}

		Lib.current.stage.window.title = TitleState.title + ' - Credits';
		trans = new MaidTransition(0, 0);
		trans.screenCenter();

        //

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        bg.scrollFactor.set(0,0); bg.screenCenter();
        add(bg);

        var shapes:FlxBackdrop = new FlxBackdrop(Paths.image('creditsMenu/shapes'), 5, 5);
        //shapes.scrollFactor.set(0,0); shapes.screenCenter();
        add(shapes);

        iconsGrp = new FlxTypedGroup<CreditsLogo>();
        for(i in getCreditsInformation()){
            var cur_logo:CreditsLogo = new CreditsLogo(i);
            cur_logo.scrollFactor.set(0,0);
            cur_logo.x = 50;
            
            iconsGrp.add(cur_logo);
        }
        add(iconsGrp);

        var shape_1:FlxSprite = new FlxSprite(500, 50).makeGraphic(700, 200, FlxColor.BLACK);
        shape_1.scrollFactor.set(0,0);
        add(shape_1);

        var shape_2:FlxSprite = new FlxSprite(500, shape_1.y + shape_1.height + 50).makeGraphic(700, 500, FlxColor.BLACK);
        shape_2.scrollFactor.set(0,0);
        add(shape_2);

        //
        
		add(trans);
		trans.transOut();
	}

    private function getCreditsInformation():Array<Dynamic> {
        var global_info:Dynamic = cast Json.parse(Assets.getText(Paths.json('credits_informtation')));
        var toReturn:Array<Dynamic> = [];

        if(global_info == null){return toReturn;}

        toReturn = global_info.credits;
        trace(toReturn);

        return toReturn;
    }
}

class CreditsLogo extends FlxSpriteGroup {
    var current_info:Dynamic;

    var backShape:FlxSprite;
    var logo:FlxSprite;

    public function new(info:Dynamic){
        this.current_info = info;
        super(0,0);
        
        setupLogo();
    }

    public function setupLogo():Void {
        if(current_info.logo == null){current_info.logo = "sugar";}

        var backShape:FlxSprite = new FlxSprite().makeGraphic(500, 500);
        if(current_info.style_1 != null){backShape.color = current_info.style_1;}
        add(backShape);

        var logo:FlxSprite = new FlxSprite(backShape.x + 10, backShape.y + 10).loadGraphic(Paths.image('creditsMenu/logos/${current_info.logo}'));
        logo.setGraphicSize(Std.int(backShape.width - 20), Std.int(backShape.height - 20)); logo.updateHitbox();
        logo.antialiasing = true;
        add(logo);
    }
}