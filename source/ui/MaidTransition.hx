package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import states.*;

class MaidTransition extends FlxSprite{

  public function new(x:Float, y:Float){
    super(x,y);

    frames = Paths.getSparrowAtlas('maidMenu/transition');
    animation.addByPrefix('in', 'in', 24, false);
    animation.addByPrefix('out', 'out', 24, false);
    setGraphicSize(Std.int(width * 1.35));
    alpha = 0;
    antialiasing = true;

    updateHitbox();
    screenCenter();
  }

  public function transIn(state:String){
    if(!exists)
        revive();
    alpha = 1;
    FlxTransitionableState.skipNextTransIn = true;
	FlxTransitionableState.skipNextTransOut = true;
    animation.play('in');
    animation.finishCallback = function(_){
        switch(state)
        {
            case 'main':
                FlxG.switchState(new MainMenuState());
            case 'story':
                FlxG.switchState(new StoryMenuState());
            case 'free':
                FlxG.switchState(new FreeplayState());
            case 'options':
                FlxG.switchState(new OptionsState());
            case 'extra':
                FlxG.switchState(new ExtraState());
            case 'mini':
                FlxG.switchState(new MiniselecState());
            case 'art':
                FlxG.switchState(new ArtBookState());
            case 'playlist':
                FlxG.switchState(new PlayListState());
        }
    }
    
  }

  public function transOut(){
    alpha = 1;
    animation.play('out');
    animation.finishCallback = function(_){
        kill();
    }
  }

  override function update(elapsed:Float){

    super.update(elapsed);
  }
}
