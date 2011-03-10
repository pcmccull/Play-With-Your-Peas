package com.mccullick.game.pwyp 
{
	import com.mccullick.utils.SpriteManager;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class Tutorial extends Sprite
	{
		public var instructions:MovieClip;
		public function Tutorial() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		}
		private function onAddedToStage(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			instructions = SpriteManager.getSprite("Instructions") as MovieClip;
			instructions.visible = false;			
			instructions.x = Settings.GAME_WIDTH / 2 ;
			instructions.y = Settings.GAME_HEIGHT / 2;
			instructions.filters = [new DropShadowFilter(5, 45, 0x333333, .5)];			
			
			this.addChild(instructions);
			this.mouseEnabled = false;
			this.mouseChildren  = false;
		}
		
		public function showStartupInstructions():void
		{
			instructions.visible = true;
			instructions.gotoAndStop(1);
		}
		public function hide():void
		{
			instructions.visible = false;
		}
		
		
		
	}

}