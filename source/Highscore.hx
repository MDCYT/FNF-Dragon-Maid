package;

import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		#if !switch
		// NGio.postScore(score, song);
		#end

		var uuid = FlxG.save.data.uuid;

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);

				var stringData = haxe.Json.stringify({
					score: Std.string(score),
					songID: song,
					dificulty: diff
				}, "\t");

				var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/record/update/" + uuid);

				http.setHeader("Content-Type", "application/json");
				http.setPostData(stringData);

				http.onStatus = function(status)
				{
					if (status == 200)
					{
						trace("Success record");
					}
					else
					{
						trace("Error record");
					}
				}

				http.request(true);
			}
			else
			{
				var stringData = haxe.Json.stringify({
					score: songScores.get(daSong),
					songID: song,
					dificulty: diff
				}, "\t");

				var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/record/update/" + uuid);

				http.setHeader("Content-Type", "application/json");
				http.setPostData(stringData);

				http.onStatus = function(status)
				{
					if (status == 200)
					{
						trace("Success record");
					}
					else
					{
						trace("Error record");
					}
				}

				http.request(true);
			}
		}
		else
		{
			setScore(daSong, score);

			var stringData = haxe.Json.stringify({
				id: uuid,
				score: Std.string(score),
				songID: song,
				dificulty: diff
			}, "\t");

			var http = new haxe.Http("https://expressjs-production-4733.up.railway.app/api/v1/record");

			http.setHeader("Content-Type", "application/json");
			http.setPostData(stringData);

			http.onStatus = function(status)
			{
				if (status == 200)
				{
					trace("Success record");
				}
				else
				{
					trace("Error record");
				}
			}

			http.request(true);
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		#if !switch
		// NGio.postScore(score, "Week " + week);
		#end

		var daWeek:String = formatSong('week' + week, diff);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';
		else if (diff == 3)
			daSong += '-maid';

		/*var judgeMan = new JudgementManager(JudgementManager.getDataByName(currentOptions.judgementWindow));
			var judgementData = judgeMan.getJudgeId(); */

		// TODO: make ^ this work so highscore shit is dependant on judge windows

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong('week' + week, diff)))
			setScore(formatSong('week' + week, diff), 0);

		return songScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
	}
}
