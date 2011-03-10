package com.mccullick.logger
{
	public class Logger
	{
		private var id:String;
		private var _bEnabled:Boolean;
		
		public function Logger(id:String, bEnabled:Boolean=true):void
		{
			this.id = id;
			this.bEnabled  = bEnabled;
		}
		
		public function log(str:Object):void
		{
			if (bEnabled)
				trace(str);
		}
		
		public function get bEnabled():Boolean { return _bEnabled; }
		
		public function set bEnabled(value:Boolean):void 
		{
			_bEnabled = value;
		}
	}
}