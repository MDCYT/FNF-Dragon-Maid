package;

// TODO: Clean up
import modchart.*;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import flixel.util.FlxAxes;
import flixel.FlxSprite;
import lime.app.Application;
import openfl.Lib;
import sys.io.File;
import flash.display.BitmapData;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;
import Shaders;
import Options;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.DynamicAccess;
import openfl.display.GraphicsShader;
import states.*;
import ui.*;
typedef LuaProperty = {
    var defaultValue:Any;
    var getter:(State,Any)->Int;
    var setter:State->Int;
}

class LuaStorage {
  public static var objectProperties:Map<String,Map<String,LuaProperty>> = [];
  public static var objects:Map<String,LuaClass> = [];
  public static var notes:Array<Note> = [];
  public static var noteIDs:Map<Note,String>=[];
  public static var noteMap:Map<String,Note>=[];
}

class LuaClass {
  public var properties:Map<String,LuaProperty> = [];
  public var methods:Map<String,cpp.Callable<StatePointer->Int> > = [];
  public var className:String = "BaseClass";
  private static var state:State;
  public var addToGlobal:Bool=true;
  public function Register(l:State){
    Lua.newtable(l);
    state=l;
    LuaStorage.objectProperties[className]=this.properties;

    var classIdx = Lua.gettop(l);
    Lua.pushvalue(l,classIdx);
    if(addToGlobal)
      Lua.setglobal(l,className);

    for (k in methods.keys()){
      Lua.pushcfunction(l,methods[k]);
      Lua.setfield(l,classIdx,k);
    }

    Lua.pushstring(l,"InternalClassName");
    Lua.pushstring(l,className);
    Lua.settable(l,classIdx);

    LuaL.newmetatable(l,className + "Metatable");
    var mtIdx = Lua.gettop(l);
    Lua.pushstring(l, "__index");
		Lua.pushcfunction(l,cpp.Callable.fromStaticFunction(index));
		Lua.settable(l, mtIdx);

    Lua.pushstring(l, "__newindex");
		Lua.pushcfunction(l,cpp.Callable.fromStaticFunction(newindex));
		Lua.settable(l, mtIdx);

    for (k in properties.keys()){
      Lua.pushstring(l,k + "PropertyData");
      Convert.toLua(l,properties[k].defaultValue);
      Lua.settable(l,mtIdx);
    }
    Lua.pushstring(l,"_CLASSNAME");
    Lua.pushstring(l,className);
    Lua.settable(l,mtIdx);

    Lua.pushstring(l,"__metatable");
    Lua.pushstring(l,"This metatable is locked.");
    Lua.settable(l,mtIdx);

    Lua.setmetatable(l,classIdx);

  };


  private static function index(l:StatePointer):Int{
    var l = state;
    var index = Lua.tostring(l,-1);
    if(Lua.getmetatable(l,-2)!=0){
      var mtIdx = Lua.gettop(l);
      Lua.pushstring(l,index + "PropertyData");
      Lua.rawget(l,mtIdx);
      var data:Any = Convert.fromLua(l,-1);
      if(data!=null){
        Lua.pushstring(l,"_CLASSNAME");
        Lua.rawget(l,mtIdx);
        var clName = Lua.tostring(l,-1);
        if(LuaStorage.objectProperties[clName]!=null && LuaStorage.objectProperties[clName][index]!=null){
          return LuaStorage.objectProperties[clName][index].getter(l,data);
        }
      };
    }else{
      // TODO: throw an error!
    };
    return 0;
  }

  private static function newindex(l:StatePointer):Int{
    var l = state;
    var index = Lua.tostring(l,2);
    if(Lua.getmetatable(l,1)!=0){
      var mtIdx = Lua.gettop(l);
      Lua.pushstring(l,index + "PropertyData");
      Lua.rawget(l,mtIdx);
      var data:Any = Convert.fromLua(l,-1);
      if(data!=null){
        Lua.pushstring(l,"_CLASSNAME");
        Lua.rawget(l,mtIdx);
        var clName = Lua.tostring(l,-1);
        if(LuaStorage.objectProperties[clName]!=null && LuaStorage.objectProperties[clName][index]!=null){
          Lua.pop(l,2);
          return LuaStorage.objectProperties[clName][index].setter(l);
        }
      };
    }else{
      // TODO: throw an error!
    };
    return 0;
  }

  public static function SetProperty(l:State,tableIndex:Int,key:String,value:Any){
    Lua.pushstring(l,key + "PropertyData");
    Convert.toLua(l,value);
    Lua.settable(l,tableIndex  );

    Lua.pop(l,2);
  }

  public static function DefaultSetter(l:State){
    var key = Lua.tostring(l,2);

    Lua.pushstring(l,key + "PropertyData");
    Lua.pushvalue(l,3);
    Lua.settable(l,4);

    Lua.pop(l,2);
  };
  public function new(){}
}

class LuaWindow extends LuaClass {
  private static var state:State;
  private static function WrapNumberSetter(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      //Lib.application.window.x = Std.int(Lua.tonumber(l,3));
      Reflect.setProperty(Lib.application.window,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }

  public function new (){
    super();
    className = "window";
    properties = [
      "x"=>{
        defaultValue:Lib.application.window.x,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.x);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "y"=>{
        defaultValue:Lib.application.window.y,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.y);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "width"=>{
        defaultValue:Lib.application.window.width,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.width);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "height"=>{
        defaultValue:Lib.application.window.height,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.height);
          return 1;
        },
        setter:WrapNumberSetter
      },
      "boundsWidth"=>{ // TODO: turn into a table w/ bounds.x and bounds.y
        defaultValue:Lib.application.window.display.bounds.width,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.display.bounds.width);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"boundsWidth is read-only.");
          return 0;
        }
      },
      "boundsHeight"=>{ // TODO: turn into a table w/ bounds.x and bounds.y
        defaultValue:Lib.application.window.display.bounds.height,
        getter: function(l:State,data:Any):Int{
          Lua.pushnumber(l,Lib.application.window.display.bounds.height);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"boundsHeight is read-only.");
          return 0;
        }
      }
    ];
  }
  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}

class LuaSprite extends LuaClass {
  private static var state:State;
  private static var stringToCentering:Map<String,FlxAxes> = [
    "X"=>X,
    "XY"=>XY,
    "Y"=>Y,
    "YX"=>XY
  ];
  public var sprite:FlxSprite;
  private function SetNumProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(sprite,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }
  private function GetNumProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushnumber(l,Reflect.getProperty(sprite,Lua.tostring(l,2)));
      return 1;
  }

  private function SetBoolProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TBOOLEAN){
        LuaL.error(l,"invalid argument #3 (boolean expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(sprite,Lua.tostring(l,2),Lua.toboolean(l,3));
      return 0;
  }

  private function GetBoolProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushboolean(l,Reflect.getProperty(sprite,Lua.tostring(l,2)));
      return 1;
  }

  private function GetStringProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushstring(l,Reflect.getProperty(sprite,Lua.tostring(l,2)));
      return 1;
  }

  private static function setScale(l:StatePointer):Int{
    // 1 = self
    // 2 = scale
    var scale = LuaL.checknumber(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.setGraphicSize(Std.int(sprite.width*scale));
    return 0;
  }

  private static var setScaleC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setScale);

  private static function setScaleX(l:StatePointer):Int{
    // 1 = self
    // 2 = scale
    var scale = LuaL.checknumber(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.scale.x = scale;
    return 0;
  }

  private static var setScaleXC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setScaleX);

  private static function setScaleY(l:StatePointer):Int{
    // 1 = self
    // 2 = scale
    var scale = LuaL.checknumber(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.scale.y = scale;
    return 0;
  }

  private static var setScaleYC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setScaleY);

  private static function getProperty(l:StatePointer):Int{
    // 1 = self
    // 2 = property
    var property = LuaL.checkstring(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    Convert.toLua(state,Reflect.getProperty(sprite,property));
    return 1;
  }

  private static var getPropertyC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(getProperty);

  private static function addSpriteAnimByPrefix(l:StatePointer):Int{
    // 1 = self
    // 2 = anim name
    // 3 = prefix
    // 4 = framerate
    // 5 = looped
    // 6 = flipX
    // 7 = flipY

    var animName = LuaL.checkstring(state,2);
    var animPrefix = LuaL.checkstring(state,3);
    var framerate:Float = 24;
    var looped:Bool = true;
    var flipX:Bool = false;
    var flipY:Bool = false;

    if(Lua.isnumber(state,4))
      framerate = Lua.tonumber(state,4);
    if(Lua.isboolean(state,5))
      looped = Lua.toboolean(state,5);

    if(Lua.isboolean(state,6))
      flipX = Lua.toboolean(state,6);

    if(Lua.isboolean(state,7))
      flipY = Lua.toboolean(state,7);

    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.animation.addByPrefix(animName,animPrefix,framerate,looped,flipX,flipY);
    return 0;
  }

  private static function addSpriteAnim(l:StatePointer):Int{
    // 1 = self
    // 2 = anim name
    // 3 = frames
    // 4 = framerate
    // 5 = looped
    // 6 = flipX
    // 7 = flipY

    var animName = LuaL.checkstring(state,2);
    LuaL.checktable(state,3);
    var frames = Convert.fromLua(state,3);
    var framerate:Float = 24;
    var looped:Bool = true;
    var flipX:Bool = false;
    var flipY:Bool = false;

    if(Lua.isnumber(state,4))
      framerate = Lua.tonumber(state,4);

    if(Lua.isboolean(state,5))
      looped = Lua.toboolean(state,5);

    if(Lua.isboolean(state,6))
      flipX = Lua.toboolean(state,6);

    if(Lua.isboolean(state,7))
      flipY = Lua.toboolean(state,7);

    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.animation.add(animName,frames,framerate,looped,flipX,flipY);
    return 0;
  }
  private static function addSpriteAnimByIndices(l:StatePointer):Int{
    var animName = LuaL.checkstring(state,2);
    var animPrefix = LuaL.checkstring(state,3);
    LuaL.checktable(state,4);
    var indices = Convert.fromLua(state,4);
    var framerate:Float = 24;
    var looped:Bool = true;
    var flipX:Bool = false;
    var flipY:Bool = false;

    if(Lua.isnumber(state,4))
      framerate = Lua.tonumber(state,4);

    if(Lua.isboolean(state,5))
      looped = Lua.toboolean(state,5);

    if(Lua.isboolean(state,6))
      looped = Lua.toboolean(state,6);

    if(Lua.isboolean(state,7))
      flipY = Lua.toboolean(state,7);

    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.animation.addByIndices(animName,animPrefix,indices,"",framerate,looped,flipX,flipY);

    return 0;
  }

  private static function loadGraphic(l:StatePointer){
    var path = LuaL.checkstring(state,2);
    Lua.getfield(state,1,"spriteName");
    var animated = false;
    var width:Int = 0;
    var height:Int = 0;
    if(Lua.isboolean(state,3))
      animated=Lua.toboolean(state,3);

    if(Lua.isnumber(state,4))
      width=Std.int(Lua.tonumber(state,4));

    if(Lua.isnumber(state,5))
      height=Std.int(Lua.tonumber(state,5));

    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    var fullPath = "assets/songs/" + PlayState.SONG.song.toLowerCase()+"/"+path+".png";
    var data:BitmapData;
    if(FileSystem.exists(fullPath) && !FileSystem.isDirectory(fullPath)){
      try{
        data = BitmapData.fromFile(fullPath);
      }catch(e:Any){
        LuaL.error(state,"FATAL ERROR: " + e);
        return 0;
      }
    }else{
      LuaL.error(state,path + " is not a valid image file!");
      return 0;
    }
    sprite.loadGraphic(data,animated,0,0,false,spriteName);
    return 0;
  }

  private static function setFrames(l:StatePointer){
    var path = LuaL.checkstring(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];

    var fullPath = "assets/songs/" + PlayState.SONG.song.toLowerCase()+"/"+path;
    var fullPathXML = fullPath + ".xml";
    var fullPathPNG = fullPath + ".png";
    var bitmapData:BitmapData;
    var content:String;
    if(FileSystem.exists(fullPathPNG) && !FileSystem.isDirectory(fullPathPNG) && FileSystem.exists(fullPathXML) && !FileSystem.isDirectory(fullPathXML) ){
      try{
        bitmapData = BitmapData.fromFile(fullPathPNG);
        content = File.getContent(fullPathXML);
      }catch(e:Any){
        LuaL.error(state,"FATAL ERROR: " + e);
        return 0;
      }
    }else{
      LuaL.error(state,path + " is not a valid spritesheet!");
      return 0;
    }
    var frames = FlxAtlasFrames.fromSparrow(bitmapData,content);
    sprite.setFrames(frames);
    return 0;
  }

  private static function changeAnimFramerate(l:StatePointer):Int{
    var animName = LuaL.checkstring(state,2);
    var framerate = LuaL.checknumber(state,3);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    if(sprite.animation.getByName(animName)==null){
      LuaL.error(state,animName + " is not a valid animation.");
      return 0;
    }
    sprite.animation.getByName(animName).frameRate=framerate;
    return 0;
  }

  private static function animExists(l:StatePointer):Int{
    var animName = LuaL.checkstring(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    Lua.pushboolean(state,sprite.animation.getByName(animName)!=null);
    return 1;
  }

  private static function screenCenter(l:StatePointer):Int{
    var type = LuaL.checkstring(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.screenCenter(stringToCentering[type]);
    Lua.pushnumber(state,sprite.x);
    Lua.pushnumber(state,sprite.y);
    return 2;
  }

  private static function playAnimSprite(l:StatePointer):Int{
    // 1 = self
    // 2 = anim
    // 3 = forced
    // 4 = reversed
    // 5 = frame
    var anim = LuaL.checkstring(state,2);
    var forced = false;
    var reversed = false;
    var frame:Int = 0;

    if(Lua.isboolean(state,3))
      forced = Lua.toboolean(state,3);

    if(Lua.isboolean(state,4))
      reversed = Lua.toboolean(state,4);

    if(Lua.isnumber(state,5))
      frame = Std.int(Lua.tonumber(state,5));

    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.animation.play(anim,forced,reversed,frame);
    return 0;
  }

  private static function tween(l:StatePointer):Int{
    // 1 = self
    // 2 = properties
    // 3 = time
    // 4 = easing-style
    LuaL.checktable(state,2);
    var properties:DynamicAccess<Any> = Convert.fromLua(state,2);
    var time = LuaL.checknumber(state,3);
    var style = LuaL.checkstring(state,4);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    var luaObj = LuaStorage.objects[spriteName];
    FlxTween.tween(sprite,properties,time,{
      ease: Reflect.field(FlxEase,style),
    });
    return 1;

  }

  private static var changeAnimFramerateC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(changeAnimFramerate);
  private static var animExistsC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(animExists);
  private static var addSpriteAnimByPrefixC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(addSpriteAnimByPrefix);
  private static var addSpriteAnimByIndicesC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(addSpriteAnimByIndices);
  private static var addSpriteAnimC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(addSpriteAnim);
  private static var screenCenterC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(screenCenter);
  private static var loadGraphicC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(loadGraphic);
  private static var setFramesC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setFrames);
  private static var playAnimSpriteC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(playAnimSprite);
  private static var tweenC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tween);

  public function new(sprite:FlxSprite,name:String,?addToGlobal:Bool=true){
    super();
    className=name;
    this.addToGlobal=addToGlobal;
    this.sprite=sprite;
    PlayState.currentPState.luaSprites[name]=sprite;
    LuaStorage.objects[name]=this;
    properties=[
      "spriteName"=>{
        defaultValue:name,
        getter:function(l:State,data:Any){
          Lua.pushstring(l,name);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"spriteName is read-only.");
          return 0;
        }
      },
      "flipX"=>{
        defaultValue:sprite.flipX,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "flipY"=>{
        defaultValue:sprite.flipY,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "x"=>{
        defaultValue:sprite.x,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "y"=>{
        defaultValue:sprite.y,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "alpha"=>{
        defaultValue:sprite.alpha,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "angle"=>{
        defaultValue:sprite.angle,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "width"=>{
        defaultValue:sprite.width,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "height"=>{
        defaultValue:sprite.height,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "visible"=>{
        defaultValue:sprite.visible,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "antialiasing"=>{
        defaultValue:sprite.antialiasing,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "active"=>{
        defaultValue:sprite.active,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "setScale"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,setScaleC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"setScale is read-only.");
          return 0;
        }
      },
      "tween"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,tweenC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"tween is read-only.");
          return 0;
        }
      },
      "getProperty"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,getPropertyC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"getProperty is read-only.");
          return 0;
        }
      },
      "addAnimByPrefix"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,addSpriteAnimByPrefixC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"addAnimByPrefix is read-only.");
          return 0;
        }
      },
      "screenCenter"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,screenCenterC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"screenCenter is read-only.");
          return 0;
        }
      },
      "loadGraphic"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,loadGraphicC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"loadGraphic is read-only.");
          return 0;
        }
      },
      "setFrames"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,setFramesC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"setFrames is read-only.");
          return 0;
        }
      },
      "playAnim"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,playAnimSpriteC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"playAnim is read-only.");
          return 0;
        }
      },
      "addAnimByIndices"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,addSpriteAnimByIndicesC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"addAnimByIndices is read-only.");
          return 0;
        }
      },
      "addAnim"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,addSpriteAnimC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"addAnim is read-only.");
          return 0;
        }
      },
      "changeAnimFramerate"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,changeAnimFramerateC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"changeAnimFramerate is read-only.");
          return 0;
        }
      },
      "animExists"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,animExistsC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"animExists is read-only.");
          return 0;
        }
      },
      "scrollFactorX"=>{ // TODO: sprite.scrollFactor.x
        defaultValue:sprite.scrollFactor.x,
        getter:function(l:State,data:Any){
          Lua.pushnumber(l,sprite.scrollFactor.x);
          return 1;
        },
        setter:function(l:State){
          if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
            LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
            return 0;
          }
          sprite.scrollFactor.set(Lua.tonumber(l,3),sprite.scrollFactor.y);
          LuaClass.DefaultSetter(l);
          return 0;
        }
      },
      "scrollFactorY"=>{ // TODO: sprite.scrollFactor.y
        defaultValue:sprite.scrollFactor.x,
        getter:function(l:State,data:Any){
          Lua.pushnumber(l,sprite.scrollFactor.y);
          return 1;
        },
        setter:function(l:State){
          if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
            LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
            return 0;
          }
          sprite.scrollFactor.set(sprite.scrollFactor.x,Lua.tonumber(l,3));
          LuaClass.DefaultSetter(l);
          return 0;
        }
      },

      "scaleX"=>{ // TODO: sprite.scale.x
        defaultValue:sprite.scale.x,
        getter:function(l:State,data:Any){
          Lua.pushnumber(l,sprite.scale.x);
          return 1;
        },
        setter:function(l:State){
          if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
            LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
            return 0;
          }
          sprite.scale.set(Lua.tonumber(l,3),sprite.scale.y);
          LuaClass.DefaultSetter(l);
          return 0;
        }
      },
      "scaleY"=>{ // TODO: sprite.scale.y
        defaultValue:sprite.scale.x,
        getter:function(l:State,data:Any){
          Lua.pushnumber(l,sprite.scale.y);
          return 1;
        },
        setter:function(l:State){
          if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
            LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
            return 0;
          }
          sprite.scale.set(sprite.scale.x,Lua.tonumber(l,3));
          LuaClass.DefaultSetter(l);
          return 0;
        }
      },

    ];
  }
  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}

class LuaCam extends LuaClass {
  private static var state:State;
  public var camera:FlxCamera;
  private function SetNumProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(camera,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }

  private function GetNumProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushnumber(l,Reflect.getProperty(camera,Lua.tostring(l,2)));
      return 1;
  }

  private function SetBoolProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TBOOLEAN){
        LuaL.error(l,"invalid argument #3 (boolean expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(camera,Lua.tostring(l,2),Lua.toboolean(l,3));
      return 0;
  }

  private function GetBoolProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushboolean(l,Reflect.getProperty(camera,Lua.tostring(l,2)));
      return 1;
  }

  private function GetStringProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushstring(l,Reflect.getProperty(camera,Lua.tostring(l,2)));
      return 1;
  }

  private static function shake(l:StatePointer):Int{
    var intensity = .05;
    var duration = .5;
    var force = true;

    if(Lua.isnumber(state,2) )
      intensity=Lua.tonumber(state,2);

    if(Lua.isnumber(state,3) )
      duration=Lua.tonumber(state,3);

    if(Lua.isboolean(state,4) )
      force=Lua.isboolean(state,4);

    Lua.getfield(state,1,"className");
    var objName = Lua.tostring(state,-1);
    var cam = PlayState.currentPState.luaObjects[objName];
    cam.shake(intensity,duration,null,force);
    return 0;
  }

  private static function addShaders(l:StatePointer):Int{
    // 1 = self
    // 2 = table of shaders
    var stuff = Convert.fromLua(state,2);

    return 0;
  }

  private static function delShaders(l:StatePointer):Int{
    // 1 = self
    // 2 = table of shaders
    var stuff = Convert.fromLua(state,2);

    return 0;
  }

  private static var shakeC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(shake);
  private static var addShadersC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(addShaders);

  public function new(cam:FlxCamera,name:String,?addToGlobal:Bool=true){
    super();
    className=name;
    this.addToGlobal=addToGlobal;
    camera=cam;
    PlayState.currentPState.luaObjects[name]=cam;
    properties = [
      "className"=>{
        defaultValue:name,
        getter:function(l:State,data:Any){
          Lua.pushstring(l,name);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"className is read-only.");
          return 0;
        }
      },
      "x"=>{
        defaultValue:cam.x,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "y"=>{
        defaultValue:cam.y,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "width"=>{
        defaultValue:cam.width,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "height"=>{
        defaultValue:cam.height,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "zoom"=>{
        defaultValue:cam.zoom,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "angle"=>{
        defaultValue:cam.angle,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "alpha"=>{
        defaultValue:cam.alpha,
        getter:GetNumProperty,
        setter:SetNumProperty
      },
      "antialiasing"=>{
        defaultValue:cam.antialiasing,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "filtersEnabled"=>{
        defaultValue:cam.filtersEnabled,
        getter:GetBoolProperty,
        setter:SetBoolProperty
      },
      "shake"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,shakeC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"shake is read-only.");
          return 0;
        }
      },
      "addShaders"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,addShadersC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"addShaders is read-only.");
          return 0;
        }
      },
    ];
  }
  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}

class LuaNote extends LuaSprite {
  private static var state:State;
  public var id:String='0';

  override function Register(l:State){
    state=l;
    super.Register(l);
  }

  public function new(note:Note){
    super(note,'note${LuaStorage.notes.length}',true);
    id = Std.string(LuaStorage.notes.length);
    LuaStorage.notes.push(note);
    LuaStorage.noteIDs.set(note,id);
    LuaStorage.noteMap.set(id,note);

    properties.set("id",{
      defaultValue:id,
      getter:function(l:State,data:Any){
        Lua.pushstring(l,id);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"id is read-only.");
        return 0;
      }
    });

    properties.set("noteData",{
      defaultValue:note.noteData,
      getter:function(l:State,data:Any){
        Lua.pushnumber(l,note.noteData);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"noteData is read-only.");
        return 0;
      }
    });

    properties.set("strumTime",{
      defaultValue:note.strumTime,
      getter:function(l:State,data:Any){
        Lua.pushnumber(l,note.strumTime);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"strumTime is read-only.");
        return 0;
      }
    });

    properties.set("manualXOffset",{
      defaultValue:note.manualXOffset,
      getter:function(l:State,data:Any){
        Lua.pushnumber(l,note.manualXOffset);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"manualXOffset is read-only.");
        return 0;
      }
    });

    properties.set("wasGoodHit",{
      defaultValue:note.wasGoodHit,
      getter:function(l:State,data:Any){
        Lua.pushboolean(l,note.wasGoodHit);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"wasGoodHit is read-only.");
        return 0;
      }
    });

    properties.set("tooLate",{
      defaultValue:note.tooLate,
      getter:function(l:State,data:Any){
        Lua.pushboolean(l,note.tooLate);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"tooLate is read-only.");
        return 0;
      }
    });

    properties.set("sustainLength",{
      defaultValue:note.sustainLength,
      getter:function(l:State,data:Any){
        Lua.pushnumber(l,note.sustainLength);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"sustainLength is read-only.");
        return 0;
      }
    });

    properties.set("isSustainNote",{
      defaultValue:note.isSustainNote,
      getter:function(l:State,data:Any){
        Lua.pushboolean(l,note.isSustainNote);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"isSustainNote is read-only.");
        return 0;
      }
    });

    properties.set("mustPress",{
      defaultValue:note.mustPress,
      getter:function(l:State,data:Any){
        Lua.pushboolean(l,note.mustPress);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"mustPress is read-only.");
        return 0;
      }
    });


  }
}

class LuaReceptor extends LuaSprite {
  private static var state:State;

  override function SetNumProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      var key = Lua.tostring(l,2);
      if(key=='x')key='desiredX';
      if(key=='y')key='desiredY';
      Reflect.setProperty(sprite,key,Lua.tonumber(l,3));
      return 0;
  }
  override function GetNumProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      var key = Lua.tostring(l,2);
      if(key=='x')key='desiredX';
      if(key=='y')key='desiredY';
      Lua.pushnumber(l,Reflect.getProperty(sprite,key));
      return 1;
  }

  private function SetAngle(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(sprite,"desiredAngle",Lua.tonumber(l,3));
      return 0;
  }
  private function GetAngle(l:State,data:Any){
      // 1 = self
      Lua.pushnumber(l,Reflect.getProperty(sprite,"desiredAngle"));
      return 1;
  }

  override function Register(l:State){
    state=l;
    super.Register(l);
  }

  public function new(receptor:Receptor,name:String,?addToGlobal:Bool=true){
    super(receptor,name,addToGlobal);

    properties.set("incomingAngle",{
      defaultValue:receptor.incomingAngle,
      getter:GetNumProperty,
      setter:SetNumProperty
    });

    properties.set("incomingNoteAlpha",{
      defaultValue:receptor.incomingNoteAlpha,
      getter:GetNumProperty,
      setter:SetNumProperty
    });

    properties.set("x",{
      defaultValue:receptor.desiredX,
      getter:GetNumProperty,
      setter:SetNumProperty
    });

    properties.set("y",{
      defaultValue:receptor.desiredY,
      getter:GetNumProperty,
      setter:SetNumProperty
    });

    properties.set("alpha",{
      defaultValue:receptor.y,
      getter:GetNumProperty,
      setter:SetNumProperty
    });

    properties.set("angle",{
      defaultValue:receptor.desiredAngle,
      getter:GetAngle,
      setter:SetAngle
    });

    properties.set("defaultX",{
      defaultValue:receptor.defaultX,
      getter:GetNumProperty,
      setter:function(l:State){
        LuaL.error(l,"defaultX is read-only.");
        return 0;
      }
    });

    properties.set("defaultY",{
      defaultValue:receptor.defaultY,
      getter:GetNumProperty,
      setter:function(l:State){
        LuaL.error(l,"defaultY is read-only.");
        return 0;
      }
    });

  }
}

class LuaCharacter extends LuaSprite {
  private static var state:State;

  private static function swapCharacter(l:StatePointer){
    // 1 = self
    // 2 = character
    var char = LuaL.checkstring(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    PlayState.currentPState.swapCharacterByLuaName(spriteName,char);

    return 0;
  }
  private static var swapCharacterC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(swapCharacter);

  private static function addOffset(l:StatePointer){
      // 1 = self
      // 2 = name
      // 3 = offsetX
      // 4 = offsetY
      var name:String = LuaL.checkstring(state,2);
      var offsetX:Float = LuaL.checknumber(state,3);
      var offsetY:Float = LuaL.checknumber(state,4);
      Lua.getfield(state,1,"spriteName");
      var spriteName = Lua.tostring(state,-1);
      var sprite = PlayState.currentPState.luaSprites[spriteName];
      sprite.addOffset(name,offsetX,offsetY);
      return 0;
  }

  private static function playAnim(l:StatePointer):Int{
    // 1 = self
    // 2 = anim
    // 3 = forced
    // 4 = reversed
    // 5 = frame
    var anim = LuaL.checkstring(state,2);
    var forced = false;
    var reversed = false;
    var frame:Int = 0;

    if(Lua.isboolean(state,3))
      forced = Lua.toboolean(state,3);

    if(Lua.isboolean(state,4))
      reversed = Lua.toboolean(state,4);

    if(Lua.isnumber(state,5))
      frame = Std.int(Lua.tonumber(state,5));

    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.playAnim(anim,forced,reversed,frame);
    return 0;
  }

  private static function leftToRight(l:StatePointer){
    // 1 = self
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.leftToRight();
    return 0;
  }

  private static function rightToLeft(l:StatePointer){
    // 1 = self
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.rightToLeft();
    return 0;
  }

  private static var playAnimC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(playAnim);
  private static var addOffsetC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(addOffset);
  private static var leftToRightC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(leftToRight);
  private static var rightToLeftC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(rightToLeft);

  public function new(character:Character,name:String,?addToGlobal:Bool=true){
    super(character,name,addToGlobal);
    properties.set("curCharacter",{
      defaultValue:character.curCharacter,
      getter:GetStringProperty,
      setter:function(l:State){
        LuaL.error(l,"curCharacter is read-only. Try calling 'changeCharacter'");
        return 0;
      }
    });
    properties.set("disabledDance",{
      defaultValue:character.disabledDance,
      getter:GetBoolProperty,
      setter:SetBoolProperty
    });
    properties.set("changeCharacter",{
      defaultValue:0,
      getter:function(l:State,data:Any){
        Lua.pushcfunction(l,swapCharacterC);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"changeCharacter is read-only.");
        return 0;
      }
    });
    properties.set("playAnim",{
      defaultValue:0,
      getter:function(l:State,data:Any){
        Lua.pushcfunction(l,playAnimC);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"playAnim is read-only.");
        return 0;
      }
    });
    properties.set("addOffset",{
      defaultValue:0,
      getter:function(l:State,data:Any){
        Lua.pushcfunction(l,addOffsetC);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"addOffset is read-only.");
        return 0;
      }
    });
    properties.set("leftToRight",{
      defaultValue:0,
      getter:function(l:State,data:Any){
        Lua.pushcfunction(l,leftToRightC);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"leftToRight is read-only.");
        return 0;
      }
    });
    properties.set("rightToLeft",{
      defaultValue:0,
      getter:function(l:State,data:Any){
        Lua.pushcfunction(l,rightToLeftC);
        return 1;
      },
      setter:function(l:State){
        LuaL.error(l,"rightToLeft is read-only.");
        return 0;
      }
    });
  }
  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}

class LuaShaderClass extends LuaClass {
  private static var state:State;
  private var shader:GraphicsShader;
  private function SetNumProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      //Reflect.setProperty(effect,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }

  private static function getProperty(l:StatePointer):Int{
    // 1 = self
    // 2 = property
    var property = LuaL.checkstring(state,2);
    Lua.getfield(state,1,"className");
    var name = Lua.tostring(state,-1);
    var shader = PlayState.currentPState.luaObjects[name];
    //Convert.toLua(state,Reflect.getProperty(shader,property));
    return 1;
  }

  private static function setProperty(l:StatePointer):Int{
    // 1 = self
    // 2 = property
    // 3 = value
    var property = LuaL.checkstring(state,2);
    var value = Convert.fromLua(state,3);
    Lua.getfield(state,1,"className");
    var name = Lua.tostring(state,-1);
    var shader = PlayState.currentPState.luaObjects[name];
    //Reflect.setProperty(shader,property,value);

    return 1;
  }

  private static var setvarC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setProperty);
  private static var getvarC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(getProperty);

  public function new(shader:GraphicsShader,shaderName:String,?addToGlobal=false){
    super();
    if(PlayState.currentPState.luaObjects.get(shaderName)!=null){
      var counter:Int = 0;
      while(PlayState.currentPState.luaObjects.get(shaderName + Std.string(counter))!=null){
        counter++;
      }
      shaderName+=Std.string(counter);
    }
    className = shaderName;
    this.addToGlobal=addToGlobal;
    this.shader=shader;
    PlayState.currentPState.luaObjects[shaderName]=shader;
    properties = [
      "className"=>{
        defaultValue:shaderName,
        getter:function(l:State,data:Any){
          Lua.pushstring(l,shaderName);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"className is read-only.");
          return 0;
        }
      },

      "setVar"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,setvarC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"setVar is read-only.");
          return 0;
        }
      },

      "getVar"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,getvarC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"getVar is read-only.");
          return 0;
        }
      },
    ];
  }

  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}

class LuaModchart extends LuaClass {
  private static var state:State;
  private var modchart:ModChart;
  private var options:Options;
  private function SetNumProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TNUMBER){
        LuaL.error(l,"invalid argument #3 (number expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(modchart,Lua.tostring(l,2),Lua.tonumber(l,3));
      return 0;
  }

  private function SetStringProperty(l:State,data:Any){
    // 1 = self
    // 2 = key
    // 3 = value
    // 4 = metatable
    if(Lua.type(l,3)!=Lua.LUA_TSTRING){
      LuaL.error(l,"invalid argument #3 (string expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
      return 0;
    }
    Reflect.setProperty(modchart,Lua.tostring(l,2),Lua.tostring(l,3));
    return 0;
  }

  private function GetNumProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushnumber(l,Reflect.getProperty(modchart,Lua.tostring(l,2)));
      return 1;
  }

  private function SetBoolProperty(l:State){
      // 1 = self
      // 2 = key
      // 3 = value
      // 4 = metatable
      if(Lua.type(l,3)!=Lua.LUA_TBOOLEAN){
        LuaL.error(l,"invalid argument #3 (boolean expected, got " + Lua.typename(l,Lua.type(l,3)) + ")");
        return 0;
      }
      Reflect.setProperty(modchart,Lua.tostring(l,2),Lua.toboolean(l,3));
      return 0;
  }

  private function GetBoolProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushboolean(l,Reflect.getProperty(modchart,Lua.tostring(l,2)));
      return 1;
  }

  private function GetStringProperty(l:State,data:Any){
      // 1 = self
      // 2 = key
      // 3 = metatable
      Lua.pushstring(l,Reflect.getProperty(modchart,Lua.tostring(l,2)));
      return 1;
  }


  public function new(modchart:ModChart){
    super();
    this.modchart=modchart;
    className = 'modchart';
    properties = [
      "className"=>{
        defaultValue:className,
        getter:function(l:State,data:Any){
          Lua.pushstring(l,className);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"className is read-only.");
          return 0;
        }
      },
      "playerNotesFollowReceptors"=>{
        defaultValue: modchart.playerNotesFollowReceptors,
        getter:GetBoolProperty,
        setter:SetBoolProperty,
      },
      "opponentNotesFollowReceptors"=>{
        defaultValue: modchart.opponentNotesFollowReceptors,
        getter:GetBoolProperty,
        setter:SetBoolProperty,
      },
      "hudVisible"=>{
        defaultValue: modchart.hudVisible,
        getter:GetBoolProperty,
        setter:SetBoolProperty,
      },
      "opponentHPDrain"=>{
        defaultValue: modchart.opponentHPDrain,
        getter:GetNumProperty,
        setter:SetNumProperty,
      },

    ];
  }

  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}

class LuaModMgr extends LuaClass {
  private static var state:State;
  private var manager:ModManager;

  /*
  private static function setScaleY(l:StatePointer):Int{
    // 1 = self
    // 2 = scale
    var scale = LuaL.checknumber(state,2);
    Lua.getfield(state,1,"spriteName");
    var spriteName = Lua.tostring(state,-1);
    var sprite = PlayState.currentPState.luaSprites[spriteName];
    sprite.scale.y = scale;
    return 0;
  }

  private static var setScaleYC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setScaleY);
  */

  private static function queueEase(l:StatePointer):Int{
    // 1 = self
    // 2 = step
    // 3 = endStep
    // 4 = modName
    // 5 = percent
    // 6 = easing style
    // 7 = player
    var step = LuaL.checknumber(state,2);
    var eStep = LuaL.checknumber(state,3);
    var modN = LuaL.checkstring(state,4);
    var perc = LuaL.checknumber(state,5);
    var ease = LuaL.checkstring(state,6);
    var player:Int = -1;

    if(Lua.isnumber(state,7))
      player = Std.int(Lua.tonumber(state,7));

    Lua.getfield(state,1,"className");
    var className = Lua.tostring(state,-1);
    var mgr = PlayState.currentPState.luaObjects[className];
    try{
      mgr.queueEase(step,eStep,modN,perc,ease,player);
    }catch(e){
      trace(e.stack,e.message);
    }
    return 0;
  }

  private static var queueEaseC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(queueEase);

  private static function queueSet(l:StatePointer):Int{
    // 1 = self
    // 2 = step
    // 3 = modName
    // 4 = percent
    // 5 = player
    var step = LuaL.checknumber(state,2);
    var modN = LuaL.checkstring(state,3);
    var perc = LuaL.checknumber(state,4);
    var player:Int = -1;

    if(Lua.isnumber(state,5))
      player = Std.int(Lua.tonumber(state,5));

    Lua.getfield(state,1,"className");
    var className = Lua.tostring(state,-1);
    var mgr = PlayState.currentPState.luaObjects[className];
    mgr.queueSet(step,modN,perc,player);
    return 0;
  }
  private static var queueSetC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(queueSet);



  public function new(mgr:ModManager,?name="modMgr",?addToGlobal=true){
    super();
    className=name;
    this.addToGlobal=addToGlobal;
    this.manager=mgr;
    PlayState.currentPState.luaObjects[name]=mgr;
    properties = [
      "className"=>{
        defaultValue:className,
        getter:function(l:State,data:Any){
          Lua.pushstring(l,className);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"className is read-only.");
          return 0;
        }
      },
      "queueSet"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,queueSetC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"queueSet is read-only.");
          return 0;
        }
      },
      "queueEase"=>{
        defaultValue:0,
        getter:function(l:State,data:Any){
          Lua.pushcfunction(l,queueEaseC);
          return 1;
        },
        setter:function(l:State){
          LuaL.error(l,"queueEase is read-only.");
          return 0;
        }
      },
    ];
  }

  override function Register(l:State){
    state=l;
    super.Register(l);
  }
}
