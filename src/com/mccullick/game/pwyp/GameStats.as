package com.mccullick.game.pwyp 
{
	import com.mccullick.filesystem.File;
	import flash.utils.ByteArray;
	import mochi.as3.MochiDigits;
	import com.adobe.serialization.json.JSON;
	import com.hurlant.crypto.symmetric.BlowFishKey;
	import com.hurlant.util.Hex;
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class GameStats 
	{
		private var _currentLevelIndex:Number;
		private var _currentLevel:Level;
		private var _levelTime:MochiDigits;
		private var _totalHappyPoints:MochiDigits;
		private var _happyPointsPerLevel:Object;
		private var _happyPoints:MochiDigits;
		private var _currentGameSpeed:MochiDigits
		private var saveObj:Object;
		public var gameInProgress:Boolean;
		
		private static var gameStats:GameStats;
		
		public function GameStats(key:PrivateConstructorKey) 
		{
			this.totalHappyPoints = new MochiDigits(0);
			this._currentGameSpeed = new MochiDigits(1);
			this._happyPointsPerLevel = new Object();
			this.gameInProgress = false;
		}
		public static function getInstance():GameStats
		{
			if (gameStats == null)
				gameStats = new GameStats(new PrivateConstructorKey());
			
			return gameStats;
		}
		
		public function get currentLevel():Level { return _currentLevel; }
		
		public function set currentLevel(value:Level):void 
		{
			_currentLevel = value;
		}
		
		
		public function get happyPoints():MochiDigits { return _happyPoints; }
		
		public function set happyPoints(value:MochiDigits):void 
		{
			_happyPoints = value;
		}
		
		public function get levelTime():MochiDigits { return _levelTime; }
		
		public function set levelTime(value:MochiDigits):void 
		{
			_levelTime = value;
		}
		
		public function get totalHappyPoints():MochiDigits { return _totalHappyPoints; }
		
		public function set totalHappyPoints(value:MochiDigits):void 
		{
			_totalHappyPoints = value;
		}
		
		public function get currentLevelIndex():Number { return _currentLevelIndex; }
		
		public function set currentLevelIndex(value:Number):void 
		{
			currentLevel = Settings.levels[value];
			_currentLevelIndex = value;
		}
		
		public function get currentGameSpeed():MochiDigits { return _currentGameSpeed; }
		
		public function set currentGameSpeed(value:MochiDigits):void 
		{
			_currentGameSpeed = value;
		}
		
		public function get happyPointsPerLevel():Object { return _happyPointsPerLevel; }
		
		public function set happyPointsPerLevel(value:Object):void 
		{
			_happyPointsPerLevel = value;
		}
		
		public function setHappyPointsForLevel(levelIndex:Number, value:MochiDigits):void
		{
			happyPointsPerLevel[levelIndex] = value;
		}
		
		public function getHappyPointsForLevel(levelIndex:Number):MochiDigits
		{
			if (happyPointsPerLevel[levelIndex] == undefined)
				return new MochiDigits(0);
			else	
				return happyPointsPerLevel[levelIndex];
		}
		
		public function save():void
		{
			//check if this is a custom level
			if (_currentLevelIndex == -1) return;
			
			var saveFile:File = new File("pwyp2");
			
			var tempSaveObject:Object = { currentLevelIndex:currentLevelIndex,
									totalHappyPoints:totalHappyPoints,
									happyPointsPerLevel:happyPointsPerLevel
								};
			var tempSaveString:String = JSON.encode(tempSaveObject);
			
			
			var key:ByteArray = Hex.toArray(Hex.fromString(Settings.LEVEL_KEY));
			var pt:ByteArray = Hex.toArray(Hex.fromString(tempSaveString));
			var bf:BlowFishKey = new BlowFishKey(key);
			bf.encrypt(pt);
			
			saveObj = new Object();
			saveObj.data = Hex.fromArray(pt);
			saveFile.save(saveObj);
		}
		public function load():void
		{
			var saveFile:File = new File("pwyp2");
			saveObj = saveFile.load();
			
			if (saveObj != null && saveObj.data != undefined)
			{
				var key:ByteArray = Hex.toArray(Hex.fromString(Settings.LEVEL_KEY));
				var pt:ByteArray = Hex.toArray(saveObj.data);
				var bf:BlowFishKey = new BlowFishKey(key);
				bf.decrypt(pt);
				var str:String = Hex.toString(Hex.fromArray(pt));
				
				var loaded:Object = JSON.decode(str);
			
				//load stats
				currentLevelIndex = loaded.currentLevelIndex+1;
				totalHappyPoints = new MochiDigits(loaded.totalHappyPoints);
				happyPointsPerLevel = loaded.happyPointsPerLevel;
				gameInProgress = true;
			}
		}
		
		
	}
	
}

class PrivateConstructorKey
{
	public function PrivateConstructorKey()
	{
		
	}
}