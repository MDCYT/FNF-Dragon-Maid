package states;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import openfl.filters.ShaderFilter;
import flixel.util.FlxGradient;
import sys.io.File;
import flixel.group.FlxSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.text.FlxTypeText;
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
    var cur_icon:Int = 0;

    var shapes:FlxBackdrop;
    var shape_1:FlxSprite;
    var shape_2:FlxSprite;

    var tblName:FlxTypeText;
    var tblRol:FlxTypeText;
    var tblDesc:FlxTypeText;

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

        shapes = new FlxBackdrop(Paths.image('creditsMenu/shapes'), 5, 5);
        shapes.velocity.set(50, 50);
        add(shapes);
        
        var gradient = FlxGradient.createGradientFlxSprite(FlxG.width, 500, [0x00FFFFFF, 0xFFFFFFFF]);
        gradient.y = FlxG.height - gradient.height;
		add(gradient);

        iconsGrp = new FlxTypedGroup<CreditsLogo>();
        for(i in getCreditsInformation()){
            var cur_logo:CreditsLogo = new CreditsLogo(i);
            cur_logo.ID = i;
            cur_logo.scrollFactor.set(0,0);
            cur_logo.x = 50;
            
            iconsGrp.add(cur_logo);
        }
        add(iconsGrp);

        shape_1 = new FlxSprite(590, 50).makeGraphic(650, 200, FlxColor.WHITE);
        shape_1.scrollFactor.set(0,0);
        add(shape_1);


        tblName = new FlxTypeText(shape_1.x, shape_1.y + 20, Std.int(shape_1.width), "", 90);
		tblName.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		tblName.font = Paths.font('usuzibold.ttf');
        tblName.alignment = CENTER;
		add(tblName);

        tblRol = new FlxTypeText(shape_1.x, tblName.y + tblName.height + 5, Std.int(shape_1.width), "", 32);
		tblRol.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		tblRol.font = Paths.font('Phonk_Contrast_DEMO.otf');
        tblRol.alignment = CENTER;
		add(tblRol);

        shape_2 = new FlxSprite(590, shape_1.y + shape_1.height + 20).makeGraphic(650, 400, FlxColor.WHITE);
        shape_2.scrollFactor.set(0,0);
        add(shape_2);
        
        tblDesc = new FlxTypeText(shape_2.x + 5, shape_2.y + 5, Std.int(shape_2.width) - 10, "", 16);
		tblDesc.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		tblDesc.font = Paths.font('Phonk_Contrast_DEMO.otf');
		add(tblDesc);

        //
        
        changeCredit();

		add(trans);
		trans.transOut();
	}
    
	override function update(elapsed:Float){
        super.update(elapsed);
    
        if(controls.UP_P){changeCredit(-1);}
        if(controls.DOWN_P){changeCredit(1);}
        if(controls.BACK){
            FlxG.sound.play(Paths.sound('cancelMenu'));
            trans.transIn('main');
        }

        for(logo in iconsGrp.members){
            var set_height:Float = 0;

            if(logo.ID < cur_icon){set_height = -(logo.height + 50);}
            if(logo.ID > cur_icon){set_height = FlxG.height + 50;}
            if(logo.ID == cur_icon){set_height = (FlxG.height/2) - (logo.height/2);}

            logo.y = FlxMath.lerp(logo.y, set_height, 0.05);
        }
    }

    public function changeCredit(value:Int = 0, force:Bool = false):Void {
        cur_icon += value; if(force){cur_icon = value;}

        if(cur_icon < 0){cur_icon = iconsGrp.members.length - 1;}
        if(cur_icon >= iconsGrp.members.length){cur_icon = 0;}

        var cur_logo:CreditsLogo = iconsGrp.members[cur_icon];

        shapes.color = cur_logo.current_info.style_1;
        shape_1.color = cur_logo.current_info.style_2;
        shape_2.color = cur_logo.current_info.style_2;

        tblName.resetText(cur_logo.current_info.name); tblName.start(0.03, true);
        tblRol.resetText(cur_logo.current_info.rol); tblRol.start(0.03, true);
        tblDesc.resetText(cur_logo.current_info.description); tblDesc.start(0.03, true);
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
    public var current_info:Dynamic;

    var backShape:FlxSprite;
    var logo:FlxSprite;

    public function new(info:Dynamic){
        this.current_info = info;
        super(0,0);
        
        setupLogo();
    }

    public function setupLogo():Void {
        if(current_info.logo == null){current_info.logo = "sugar";}
        if(current_info.style_1 == null){current_info.style_1 = 0xffb6fb;}
        if(current_info.style_2 == null){current_info.style_2 = 0xfae2f9;}

        var backShape:FlxSprite = new FlxSprite().makeGraphic(500, 500);
        backShape.color = current_info.style_2;
        add(backShape);

        var logo:FlxSprite = new FlxSprite(backShape.x + 10, backShape.y + 10).loadGraphic(Paths.image('creditsMenu/logos/${current_info.logo}'));
        logo.setGraphicSize(Std.int(backShape.width - 20), Std.int(backShape.height - 20)); logo.updateHitbox();
        logo.antialiasing = true;
        add(logo);
    }
}