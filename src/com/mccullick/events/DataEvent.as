package com.mccullick.events{
	import flash.events.Event;

	public class DataEvent extends Event
	{		
		private var _data:Object;

		public function DataEvent(type:String,  data:Object ) {
			super( type);
			this.data = data;
		}
		
		public function get data():Object { return _data; }
		
		public function set data(value:Object):void 
		{
			_data = value;
		}
	}
}