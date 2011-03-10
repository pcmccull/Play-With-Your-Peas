package com.mccullick.game.pwyp 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public interface SpecialItem 
	{
		function createSprite():Sprite;
		function getSprite():Sprite;
		function onHit():void
		
	}
	
}