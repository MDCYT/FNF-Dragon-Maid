package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.*;

using StringTools;

class DialogueChat extends FlxSpriteGroup
{
    public var isFlip:Bool = false;
    public var targetY:Float = 0;

    public var hasAppeared:Bool = false;
    public var defaultX:Float = 0;

    public var box:FlxSprite;
    public var text:FlxText;
    public var portrait:FlxSprite;

    public function new(char:String, face:String, dialogue:String, flip:String){
        super();

        box = new FlxSprite().loadGraphic(CoolUtil.getBitmap(Paths.image('chatBox/box')));
        box.antialiasing = true;
        
        add(box);

        text = new FlxText(20, 20, Std.int(FlxG.width * 0.6), dialogue, 32);
		text.font = Paths.font("Claphappy.ttf");
		text.color = FlxColor.WHITE;
        text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        text.antialiasing = true;
		add(text);

        portrait = new FlxSprite(30,-70);
        portrait.frames = Paths.getSparrowAtlas('chatBox/characters/' + char);
		portrait.animation.addByPrefix('face', face, 24, false);
        portrait.animation.play('face');
        portrait.antialiasing = true;
        add(portrait);

        switch (flip){
            case 'right', 'r', 'true', 't':{
                isFlip = false;
                box.flipX = true;
                portrait.setPosition(740, -70);
                this.x = 1999;
            }
            default:{
                isFlip = true;
                box.flipX = false;
                text.setPosition(340, 20);
                this.x = -1999;
            }
        }

        switch(char){
            case 'kobayashi':{
                isFlip = !isFlip;
                portrait.offset.set(60, 15);
            }
            case 'tohru':{
                isFlip = !isFlip;
                portrait.offset.set(30, -5);
            }
            case 'boyfriendMaid':{
                portrait.offset.x += 10;
            }
        }
        portrait.flipX = isFlip;
    }

    override function update(elapsed:Float){

        y = FlxMath.lerp(y, (targetY * 230) + FlxG.height - 170, 0.17);
        if(hasAppeared){
            if(box.flipX){
                x = FlxMath.lerp(x, 210, 0.17);
            }else{
                x = FlxMath.lerp(x, -65, 0.17);
            }
        }
        
        super.update(elapsed);
    }
}