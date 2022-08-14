package;

import flixel.FlxBasic;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;

class CoinBar {
  
  public static function purchase(presio:Int, event:String){
    if (FlxG.save.data.coin >= presio){
      FlxG.save.data.coin -= presio;
      FlxG.sound.play(Paths.sound('purchase'));
      checkOut(event);
    }
    else if (FlxG.save.data.coin < presio){
      FlxG.sound.play(Paths.sound('nop'));
    }
  }

  public static function addCoins(coins:Int){
		var uuid = FlxG.save.data.uuid;
		var oldCoins = FlxG.save.data.coin;
		if(uuid==null) {
			return FlxG.save.data.coin = oldCoins + coins;
		} else{
			FlxG.save.data.coin = oldCoins + coins;
	
			var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/coins/" + uuid);

			http.setHeader("Content-Type", "application/json");
			http.setPostData(haxe.Json.stringify({
				"coins": FlxG.save.data.coin
			}));

			http.onStatus = function(status) {
                if(status == 200)
                {
                    trace("Success!");
                }
                else
                {
                    trace("Error!");
                }
            }

			http.onData = function(data) {
				trace(data);
			}

			http.request(true);

			return FlxG.save.data.coin;
		}
	}

  public static function deletCoins(coins:Int){
		var uuid = FlxG.save.data.uuid;
		var oldCoins = FlxG.save.data.coin;
		if(uuid==null) {
			return FlxG.save.data.coin = oldCoins - coins;
		} else{
			FlxG.save.data.coin = oldCoins - coins;
	
			var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/coins/" + uuid);

			http.setHeader("Content-Type", "application/json");
			http.setPostData(haxe.Json.stringify({
				"coins": FlxG.save.data.coin
			}));

			http.onStatus = function(status) {
                if(status == 200)
                {
                    trace("Success!");
                }
                else
                {
                    trace("Error!");
                }
            }

			http.onData = function(data) {
				trace(data);
			}

			http.request(true);

			return FlxG.save.data.coin;
		}
	}

  public static function checkOut(event:String){

    FlxG.camera.flash(FlxColor.WHITE, 1);

    switch (event){
      
      case 'killers':
        FlxG.save.data.killer = true;
    }
  }
}
