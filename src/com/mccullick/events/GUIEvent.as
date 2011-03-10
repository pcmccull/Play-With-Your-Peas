package com.mccullick.events 
{
	import flash.events.Event;
	
	/**
	* ...
	* @author Philip McCullick
	*/
	public class GUIEvent extends Event 	
	{
		
		public static const VALUE_CHANGED:String = "VALUE_CHANGED";
		public static const COMPLETED:String = "COMPLETED";
		
		
		private var data:Object;
		
		public function GUIEvent(type:String,	data:Object, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.data = data;
			
		} 
		
		public function get _data():Object
		{
			return data;
		}
		
		public override function clone():Event 
		{ 
			return new GUIEvent(type, data, bubbles, cancelable);
		}
		
		public override function toString():String 
		{ 
			return formatToString("GUIEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}