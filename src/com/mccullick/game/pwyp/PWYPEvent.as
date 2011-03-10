package com.mccullick.game.pwyp 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class PWYPEvent extends Event 
	{
		private var _data:Object;
		public function PWYPEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PWYPEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PWYPEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object { return _data; }
		
		public function set data(value:Object):void 
		{
			_data = value;
		}
		
	}
	
}