package ui;

#if desktop
import Discord.DiscordClient;
#end
import flixel.graphics.FlxGraphic;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Matrix;
import flixel.FlxSprite;
import lime.ui.FileDialog;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.addons.ui.FlxInputText;
import states.*;
import uuid.*;

class Profile extends FlxSpriteGroup {
  public var coin:FlxSprite;
  public var bar:FlxSprite;
  public var coinTxt:FlxText;
  public var initCoin:Bool = FlxG.save.data.instCoin;
  public var colors:Array<String> = ['bf', 'red', 'yellow', 'blue'];
  public var colorBar:Array<FlxColor> = [0xFF318696, 0xFF963140,0xFF4f9631,0xFF783196];
  public var pencil:FlxSpriteGroup;
  public var isOpen:Bool = false;
  public var noSpam:Bool = false;
  public var colision:FlxSpriteGroup;
  public var nameText:FlxInputText;
  public var proTxt:FlxText;
  public var user:String;
  public var icon:FlxSprite;
  public var progress:FlxBar;
  public var intPro:Int = FlxG.save.data.userProgress;
  public var bronze:FlxSprite;
  public var silver:FlxSprite;
  public var gold:FlxSprite;
  public var inEdit:Bool = false;
  public var themeColor:FlxColor;

  public var isCustom:Bool = FlxG.save.data.customPfp; //CARGO LAS PFP :V

  public var numColor:Int = 0;

  var allColor:FlxColor;
  var text = Paths.getSparrowAtlas('profile/userTrophies');

  public function new(x:Float, y:Float, daColor:Int = 0){
    super(x,y);

    numColor = daColor;
    themeColor = daColor;

    bar = new FlxSprite(0, 0);
    bar.frames = Paths.getSparrowAtlas('profile/rectangleProfile');
    bar.animation.addByPrefix('bf', 'bf', 24, false);
    bar.animation.addByPrefix('red', 'red', 24, false);
    bar.animation.addByPrefix('yellow', 'yellow', 24, false);
    bar.animation.addByPrefix('blue', 'blue', 24, false);
    bar.antialiasing = false;
    bar.updateHitbox();

    bar.animation.play(colors[daColor]);

    pencil = new FlxSpriteGroup();
    colision = new FlxSpriteGroup();

    for (i in 0...2){
      var pen:FlxSprite = new FlxSprite();
      pen.frames  = Paths.getSparrowAtlas('profile/pencil');
      pen.alpha = 0;

      var col:FlxSprite = new FlxSprite().makeGraphic(193, 203, FlxColor.BLACK);
      col.alpha = 0;

      for (color in 0...colors.length){
        pen.animation.addByPrefix(colors[color], colors[color], 24, false);
        pen.animation.play(colors[daColor]);
        pen.alpha = 0;
      }

      if (i == 0){
        pen.setPosition(490, 118);
        col.setGraphicSize(193, 203);
        col.updateHitbox();
        col.setPosition(70, 110);
      }
      else {
        pen.setPosition(230, 274);
        col.setGraphicSize(242, 38);
        col.updateHitbox();
        col.setPosition(280, 110);
      }

      pencil.add(pen);
      colision.add(col);
    }

    coin = new FlxSprite(675, -5);
    coin.frames = Paths.getSparrowAtlas('profile/coin');
    coin.animation.addByPrefix('idle', 'idleCoin0', 24, true);
    coin.scale.set(0.3, 0.3);
    coin.antialiasing = true;
    coin.updateHitbox();

    coin.animation.play('idle');

    coinTxt = new FlxText(360, 6, 300, '');
    coinTxt.setFormat(Paths.font('coinFont.ttf'), 20, FlxColor.WHITE, RIGHT);
    coinTxt.alpha = 1;

    var box = new Inputbox(0, 0, 233, FlxG.save.data.user, 20, FlxColor.BLACK, FlxColor.TRANSPARENT);
		nameText = box;
    box.alignment = LEFT;
    nameText.setFormat(Paths.font('userFont.ttf'), 20, FlxColor.BLACK);
    nameText.setPosition(283, -384);

    progress = new FlxBar(278, 272, LEFT_TO_RIGHT, 238, 28, this, 'intPro', 0, 100);
    progress.createFilledBar(0xFFFFFFFF, colorBar[daColor]);

    proTxt = new FlxText(375, 275, FlxG.save.data.userProgress + '%', 15);
    proTxt.setFormat(Paths.font('userFont.ttf'), 15, FlxColor.WHITE, CENTER);
    allColor = colorBar[daColor];

    add(colision);
    add(bar);

    switch(isCustom){
      case true:
        loadPfp(FlxG.save.data.customPfpPath);
      case false:
        loadIcon();
    }
    
    add(coin);
    add(pencil);
    add(coinTxt);
    add(progress);
    add(proTxt);
    add(box);
    add(nameText);

    if (FlxG.save.data.bronze){
      bronze = new FlxSprite(274, 171);
      bronze.frames = text;
      bronze.animation.addByPrefix('bronze', 'bronze');
      bronze.animation.play('bronze');

      add(bronze);
    }
    if(FlxG.save.data.silver){
      silver = new FlxSprite(274 + bronze.height + 1, 171);
      silver.frames = text;
      silver.animation.addByPrefix('silver', 'silver');
      silver.animation.play('silver');

      add(silver);
    }
    if (FlxG.save.data.gold){
      gold = new FlxSprite(silver.x + silver.height + 1, 171);
      gold.frames = text;
      gold.animation.addByPrefix('gold', 'gold');
      gold.animation.play('gold');

      add(gold);
    }

  }

  public function editUser(){
    nameText.hasFocus = true;

		if (nameText.text == '')
			  nameText.caretIndex = 0;
  }

  public function discordChange(?pfp:String){
    DiscordClient.changePresence("Profile: " + FlxG.save.data.user, "Coins: " + FlxG.save.data.coin, null, null, null, pfp);
  }

  public function setNewPfp(color:Int){

    FlxG.save.data.userTheme = color;
    discordChange(colors[color]);

    trace(color);
    
    pencil.members[0].animation.play(colors[color]);
    pencil.members[1].animation.play(colors[color]);

    allColor = colorBar[color];

    proTxt.kill();
    progress.kill();

    progress = new FlxBar(278, 272, LEFT_TO_RIGHT, 238, 28, this, 'intPro', 0, 100);
    progress.createFilledBar(0xFFFFFFFF, colorBar[color]);
    add(progress);

    proTxt = new FlxText(375, 275, FlxG.save.data.userProgress + '%', 15);
    proTxt.setFormat(Paths.font('userFont.ttf'), 15, FlxColor.WHITE, CENTER);
    add(proTxt);

    if (!isCustom)
      icon.animation.play(colors[color]);
    bar.animation.play(colors[color]);

    var avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/bf.png";

    switch(FlxG.save.data.userTheme){
      case 0:
          avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/bf.png";
      case 1:
          avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/gf.png";
      default:
          avatar = "https://expressjs-production-4733.up.railway.app/img/avatars/bf.png";
    }

    var stringData = haxe.Json.stringify({
      url: avatar
    }, "\t");

    var uuid = FlxG.save.data.uuid;

    var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/avatar/" + uuid);

    
    http.addHeader('Content-Type', 'application/json');
    http.setPostData(stringData);

    http.onStatus = function(status) {
        if(status == 200)
        {
            trace("Success avatar!");
        }
        else
        {
            trace("Error avatar!");
        }
    }

    http.request(true);

  }

  public function userOpen(op:Bool){
		  if (op){
        this.active = true;

			  discordChange();

			  FlxTween.tween(this, {y: 153.5, alpha: 1}, 0.7, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween){
			    noSpam = true;
          isOpen = true;
				  new FlxTimer().start(0.5, function(tmr:FlxTimer){
					  noSpam = false;
				  });
			  }});
		  }
		  else{
			  #if desktop
				  DiscordClient.changePresence("Main Menu", null);
			  #end

        nameText.hasFocus = false;
        
			  noSpam = true;
			  isOpen = false;
			  FlxTween.tween(this, {y: 500, alpha: 0}, 0.7, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween){
				  new FlxTimer().start(0.5, function(tmr:FlxTimer){
					  noSpam = false;
				  });
			  }});
		  }
	}

  var daObject:Int = 0;
  var pene:Int = 0;
  var newPfp:FlxSprite;
  var bitmap:BitmapData;
  var ifLoaded:Bool = false;

  function loadPfp(path:String = '') {
    ifLoaded = true;
    FlxG.save.data.customPfp = true;

    newPfp = new FlxSprite(0, 0);
		newPfp.makeGraphic(0, 0, FlxColor.BLACK);
		newPfp.antialiasing = true;

		add(newPfp);

    bitmap = BitmapData.fromFile(path);
    _showImage(bitmap);
  }

  function loadIcon() {
    FlxG.save.data.customPfp = false;

    icon = new FlxSprite(75, 115);
    icon.frames = Paths.getSparrowAtlas('profile/pfp');
    icon.animation.addByPrefix('bf', 'bf');
    icon.animation.addByPrefix('red', 'gf');
    icon.animation.addByPrefix('blue', 'elma');
    icon.setGraphicSize(183, 192);
    icon.animation.play(colors[themeColor]);
    icon.updateHitbox();
    icon.antialiasing = true;
    add(icon);
  }

  private function selecPfp():Void {
    trace('hola');
    
    var vent = new FileDialog();
    vent.onSelect.add(function(str) {
      ifLoaded = false;
      newPfp = new FlxSprite(0, 0);
		  newPfp.makeGraphic(0, 0, FlxColor.BLACK);
		  newPfp.antialiasing = true;


		  add(newPfp);

      FlxG.save.data.customPfp = true;

      FlxG.save.data.customPfpPath = str;
      bitmap = BitmapData.fromFile(str);
      _showImage(bitmap);
      trace(str);
    });
    vent.browse();
  }

	
	var _displayWidth:Float;
	var _displayHeight:Float;

  function _showImage(Data:BitmapData):Void
    {  
      newPfp.scale.set(1, 1);

      var imgWidth:Float = FlxG.width / Data.width;
      var imgHeight:Float = FlxG.height / Data.height;
  
      var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

      _displayWidth = Data.width * scale;
      _displayHeight = Data.height * scale;
      newPfp.makeGraphic(Std.int(_displayWidth), Std.int(_displayHeight), FlxColor.BLACK);
  
      var data2:BitmapData = newPfp.pixels.clone();
      var matrix:Matrix = new Matrix();
      matrix.identity();
      matrix.scale(scale, scale);
      data2.fillRect(data2.rect, FlxColor.BLACK);
      data2.draw(Data, matrix, null, null, null, true);
      newPfp.pixels = data2;
      newPfp.setGraphicSize(183, 194);
      newPfp.updateHitbox();
  
      if (!ifLoaded){
        newPfp.x += 75;
        newPfp.y += 113;
        trace(newPfp.x + ' ' + newPfp.y);
      }
      else{
        newPfp.x += 75;
        newPfp.y += 113;
        trace(newPfp.x + ' ' + newPfp.y);
      }

      trace(newPfp.color);


    }

  override function update(elapsed:Float){

    //PROGRESS CHECK /////////////

    FlxG.save.data.userProgress = intPro;

    if (FlxG.save.data.userProgress > 100){
      FlxG.save.data.userProgress = 100;
    }

    if (intPro < 50)
      proTxt.color = allColor;
    else
      proTxt.color = FlxColor.WHITE;
    
    if (intPro > 100){
      intPro = 100;
    }

    proTxt.text = FlxG.save.data.userProgress + '%';
    
    //USER Y COIN /////////////

    if (FlxG.mouse.pressed && FlxG.keys.pressed.SHIFT){
      nameText.setPosition(FlxG.mouse.x, FlxG.mouse.y);
      trace('name ' + nameText.x + ' ' + nameText.y);
    }

    user = nameText.text;

    if (FlxG.mouse.overlaps(colision.members[0]) && isOpen){
      pencil.members[1].alpha = 1;
    }
    else
      pencil.members[1].alpha = 0;

    if (FlxG.mouse.overlaps(colision.members[1]) && isOpen){
      pencil.members[0].alpha = 1;
    }
    else 
      pencil.members[0].alpha = 0;

    if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(colision.members[0])){
      editUser();
    }
    if (FlxG.mouse.justPressedRight && FlxG.mouse.overlaps(colision.members[0])){
      numColor ++;
      trace(numColor);
      if (numColor > 3)
        numColor = 0;
      setNewPfp(numColor);
    }

    if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(colision.members[0])){
      selecPfp();
    }

    if (FlxG.save.data.coin < 0)
    {
      FlxG.save.data.coin = 0;
    }
    coinTxt.text = '' + FlxG.save.data.coin;

    super.update(elapsed);
  }
}
