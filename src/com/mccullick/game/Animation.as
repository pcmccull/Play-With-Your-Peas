package com.mccullick.game 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	* ...
	* @author Philip McCullick
	*/
	public class Animation implements IEventDispatcher
	{
		public static const COMPLETED:String = "COMPLETED";
		private var lastUpdateTime:Number;
		
		
		public function Animation(animationXML:XML, stage:DisplayObject) 
		{
			animTimer = new Timer(10);
			
			animTimer.addEventListener(TimerEvent.TIMER, update);	
		}
		
		public function start():void
		{
			animTimer.start();
			lastUpdateTime = getTimer();
			//dispatchEvent(new Event(COMPLETED));
		}
		private function update(evt:TimerEvent):void
		{
			var dt:Number = getTimer() - lastUpdateTime;
			
			
			
		}
		
		/*****************************************
		 * 
		 *   EVENT DISPATCHER CODE 
		 * 
		 */
		protected var disp:EventDispatcher;
		public function addEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false, p_priority:int=0, p_useWeakReference:Boolean=false):void {
			if (disp == null) { disp = new EventDispatcher(); }
			disp.addEventListener(p_type, p_listener, p_useCapture, p_priority, p_useWeakReference);
		}
		public function removeEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false):void {
			if (disp == null) { return; }
			disp.removeEventListener(p_type, p_listener, p_useCapture);
		}
		public function dispatchEvent(p_event:Event):Boolean {
			if (disp == null) { return false; }
			
			return disp.dispatchEvent(p_event);
		}
		public function hasEventListener(type:String):Boolean{
			return disp.hasEventListener(type);
		}
		public function willTrigger(type:String):Boolean {
			return disp.willTrigger(type);
		}
    

		/*
		 * 
		 *  END EVENT DISPATCHER CODE 
		 * 
		 *****************************************/
		
	}
	
}