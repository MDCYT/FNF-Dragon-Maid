package;
import flixel.system.debug.log.LogStyle;
import flixel.FlxG;
using StringTools;
import JudgementManager;
class EngineData {
  public static var LUAERROR:LogStyle = new LogStyle("[MODCHART] ", "FF8888", 12, false, false, false, null, true);
  public static var characters:Array<String> = [];
  public static var noteTypes:Array<String> = ["default","alt","mine"];
  public static var validJudgements:Array<String> = ["epic","sick","good","bad","shit","miss"];
  public static var defaultJudgementData:JudgementInfo = {
    comboBreakJudgements: ["shit"],
    judgementHealth: {sick: 0.8, good: 0.4, bad: 0, shit:-2, miss: -5},
    judgements: ["sick","good","bad","shit"],
    judgementAccuracy: {sick: 100, good: 80, bad: 50, shit: -75, miss: -240},
    judgementScores: {sick:350, good:100, bad:0, shit:-50, miss:-100},
    judgementWindows: {sick: 43, good: 85, bad: 126, shit: 166, miss: 180}

    // miss window acts as a sort of "antimash"
  };
  public static var createThread=false;
  public static var options:Options;
  public static var weeksUnlocked:Array<Bool>=[true, true, true];
  public static var mustUnlockWeeks:Bool=false; // TODO: make this work
  public static var weekData:Array<WeekData> = [
    new WeekData(0,'',[
      new SongData("Tutorial","gf",0),
    ]),
    new WeekData(1,'tohru',[
      "serva",
      "scaled"
    ]),
    new WeekData(2,'elma',[
      "electro_trid3nt"
    ]),
    new WeekData(3,'tohru',[
      "killer-scream"
    ]),
    new WeekData(4,'dragon',[
      "burn-it-all"
    ]),
  ];

  public static function initSave()
  {
    // TROPHIES
    if (FlxG.save.data.bronze == null)
        FlxG.save.data.bronze = false;

    if (FlxG.save.data.silver == null)
        FlxG.save.data.silver = false;

    if (FlxG.save.data.gold == null)
        FlxG.save.data.gold = false;

    // EXTRA SONGS
    if (FlxG.save.data.bad == null)
        FlxG.save.data.bad = false;

    if (FlxG.save.data.killer == null)
        FlxG.save.data.killer = false;


    // PROFILE NAME
    if (FlxG.save.data.user == null)
        FlxG.save.data.user = '';

    if (FlxG.save.data.userTheme == null)
        FlxG.save.data.userTheme = 0;

    if (FlxG.save.data.userProgress == null)
      FlxG.save.data.userProgress = 0;

    //UNLOCKS WEEK
		if (FlxG.save.data.maidSkin == null)
        FlxG.save.data.maidSkin = false;

		if (FlxG.save.data.unlockedFinal == null)
        FlxG.save.data.unlockedFinal = false;

		if (FlxG.save.data.maidDiff == null)
        FlxG.save.data.maidDiff = false;

		if (FlxG.save.data.coin == null)
        FlxG.save.data.coin = 0;

		if (FlxG.save.data.bestScore == null)
        FlxG.save.data.bestScore = 0;

    if (FlxG.save.data.maidSkin == null)
        FlxG.save.data.maidSkin = false;

    //Unlovked Weeks Trophies
    // Normal
    if (FlxG.save.data.tohruWeek == null)
        FlxG.save.data.tohruWeek = false;

    if (FlxG.save.data.elmaWeek == null)
        FlxG.save.data.elmaWeek = false;

    // Full Chaos
    if (FlxG.save.data.tohruWeekChaos == null)
        FlxG.save.data.tohruWeekChaos = false;

    if (FlxG.save.data.elmaWeekChaos == null)
        FlxG.save.data.elmaWeekChaos = false;

    // INSTRUCTIONS
    
    if (FlxG.save.data.instCoin == null)
        FlxG.save.data.instCoin = true;

    if (FlxG.save.data.instruction = null)
        FlxG.save.data.instruction = true;

    // MINIGAMES

    if (FlxG.save.data.dragonHunt == null)
        FlxG.save.data.dragonHunt = false;

    if (FlxG.save.data.goldDragon = null)
        FlxG.save.data.goldDragon = false;

  }
}

class SongData {
  public var displayName:String = 'Tutorial';
  public var chartName:String = 'tutorial';
  public var freeplayIcon:String = 'gf';
  public var weekNum:Int = 0;
  public var loadingPath:String = '';
  public function new(name:String='Tutorial',freeplayIcon:String='gf',weekNum:Int=0,?chartName:String,?path:String){
    if(chartName==null){
      chartName=name.replace(" ","-").toLowerCase();
    }

    if(path==null){
      path = 'week${weekNum}';
    }
    loadingPath=path;

    this.displayName=name;
    this.freeplayIcon=freeplayIcon;
    this.weekNum=weekNum;
    this.chartName=chartName;
  }

  public function formatDifficulty(diffNum:Int=0){
    var name='';
    switch (diffNum){
      case 0:
        name = '${chartName}-harmony';
      case 1:
        name = '${chartName}-chaos';
    };
    return name;
  }
}

class WeekData {
  public var songs:Array<SongData>=[];
  public var character:String = '';
  public var protag:String = 'bf';
  public var lover:String='gf';
  public var weekNum:Int = 0;
  public var loadingPath:String = '';

  public function new(weekNum:Int=0,character:String='',songs:Array<Dynamic>,?protag:String='bf',?lover:String='gf',?path:String){
    if(path==null){
      path = 'week${weekNum}';
    }
    var songData:Array<SongData>=[];
    for(stuff in songs){
      switch(Type.typeof(stuff)){
        case TClass(String):
          songData.push(new SongData(stuff,character,weekNum,null,path));
        case TClass(SongData):
          songData.push(stuff);
        default:
          trace('cannot handle ${Type.typeof(stuff)}');
      }
    }
    loadingPath=path;

    this.protag=protag;
    this.lover=lover;
    this.songs=songData;
    this.weekNum=weekNum;
    this.character=character;
  }

  public function getByChartName(name:String):Null<SongData>{
    for(data in songs){
      if(data.chartName==name){
        return data;
      }
    }
    return null;
  }

  public function getCharts(){
    var charts=[];
    for(data in songs){
      charts.push(data.chartName.toLowerCase() );
    }
    return charts;
  }
}
