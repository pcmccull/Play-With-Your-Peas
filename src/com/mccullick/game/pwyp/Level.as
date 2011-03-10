package com.mccullick.game.pwyp 
{
	import com.adobe.serialization.json.JSON;
	import com.hurlant.crypto.symmetric.BlowFishKey;
	import com.hurlant.util.Hex;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import mochi.as3.MochiDigits;
	import mx.utils.StringUtil;
	
	/**
	 * A Level will describe all of the objects needed to start a new level
	 * @author Philip McCullick
	 */
	public class Level 
	{
		private var _title:String;
		private var _tools:Array;
		private var _startingBlocks:Array;
		private var _entrancePoint:Point;
		private var _specialItems:Array;
		private var _exitPoint:Point;
		private var _targetScore:MochiDigits;
		private var _numberOfPeas:MochiDigits;	
		private var _background:String;
		private var _scale:Number;
		private var _bronze:MochiDigits;
		private var _silver:MochiDigits;
		private var _gold:MochiDigits;
		private var _tutorials:Array;
		
		
		public function Level(title:String, tools:Array, startingBlocks:Array, 
							entrancePoint:Point, exitPoint:Point, 
							targetScore:MochiDigits, numberOfPeas:MochiDigits, background:String, scale:Number, specialItems:Array, bronze:MochiDigits, silver:MochiDigits, gold:MochiDigits, tutorials:Array=null ) 
		{
			this._title = title;
			this._tools = tools;
			this._startingBlocks = startingBlocks;
			this._entrancePoint = entrancePoint;
			this._exitPoint = exitPoint;
			this._targetScore = targetScore;
			this._numberOfPeas = numberOfPeas;
			this._background = background;		
			this._scale = scale;
			this._specialItems = specialItems;
			this.bronze = bronze;
			this.silver = silver;
			this.gold = gold;
			this.tutorials = tutorials;
		}
		
		public static function levelFromCode(code:String):Level
		{
			var key:ByteArray = Hex.toArray(Hex.fromString("I Love Kim"));
			var pt:ByteArray = Hex.toArray(code);
			var bf:BlowFishKey = new BlowFishKey(key);
			bf.decrypt(pt);
			var str:String = Hex.toString(Hex.fromArray(pt));
			
			var lvl:Object = JSON.decode(str);
		
			return new Level(lvl.title, lvl.tools, lvl.startingBlocks, 
						new Point(lvl.entrancePointX, lvl.entrancePointY), 
						new Point(lvl.exitPointX, lvl.exitPointY),
						new MochiDigits(lvl.targetScore), 
						new MochiDigits(lvl.numberOfPeas),
						lvl.background,
						lvl.scale,
						lvl.specialItems,
						new MochiDigits(lvl.bronze),
						new MochiDigits(lvl.silver),
						new MochiDigits(lvl.gold));
						
						
		}
		
		public function levelToCode():String
		{
			var levelObject:Object = { title:title,
								tools:tools,
								startingBlocks:startingBlocks,
								entrancePointX:entrancePoint.x,
								entrancePointY:entrancePoint.y,
								exitPointX:exitPoint.x,
								exitPointY:exitPoint.y,
								targetScore:targetScore.value,
								numberOfPeas:numberOfPeas.value,
								background:background,
								scale:scale,
								specialItems:specialItems,
								bronze:bronze.value,
								silver:silver.value,
								gold:gold.value
								};
			var levelCode:String = JSON.encode(levelObject);
			
			
			var key:ByteArray = Hex.toArray(Hex.fromString(Settings.LEVEL_KEY));
			var pt:ByteArray = Hex.toArray(Hex.fromString(levelCode));
			var bf:BlowFishKey = new BlowFishKey(key);
			bf.encrypt(pt);
			return Hex.fromArray(pt);
									
		}
		
		public function get title():String { return _title; }
		public function get tools():Array { return _tools; }
		public function get startingBlocks():Array { return _startingBlocks; }
		public function get entrancePoint():Point { return _entrancePoint; }
		public function get exitPoint():Point { return _exitPoint; }
		public function get targetScore():MochiDigits { return _targetScore; }
		public function get numberOfPeas():MochiDigits { return _numberOfPeas; }
		public function get background():String { return _background; }				
		public function get scale():Number { return _scale; }
		
		public function get specialItems():Array { return _specialItems; }
		
		public function set specialItems(value:Array):void 
		{
			_specialItems = value;
		}
		
		public function get bronze():MochiDigits { return _bronze; }
		
		public function set bronze(value:MochiDigits):void 
		{
			_bronze = value;
		}
		
		public function get silver():MochiDigits { return _silver; }
		
		public function set silver(value:MochiDigits):void 
		{
			_silver = value;
		}
		
		public function get gold():MochiDigits { return _gold; }
		
		public function set gold(value:MochiDigits):void 
		{
			_gold = value;
		}
		
		public function get tutorials():Array { return _tutorials; }
		
		public function set tutorials(value:Array):void 
		{
			_tutorials = value;
		}
		
	}
	
}