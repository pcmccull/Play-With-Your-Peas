package com.mccullick.game.pwyp 
{
	import com.mccullick.events.DataEvent;
	import com.mccullick.utils.SpriteManager;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class CoinSpecialItem implements SpecialItem
	{
		public var sprite:Sprite;
		public function CoinSpecialItem() 
		{
			
		}
		
		/* INTERFACE com.mccullick.game.pwyp.SpecialItem */
		
		public function createSprite():Sprite
		{
			if (sprite == null)
				sprite = SpriteManager.getSprite("Coin") as Sprite;
			
			return sprite;
		}
		
		public function getSprite():Sprite
		{
			return sprite;
		}
		
		public function onHit():void
		{
			PlayWithYourPeas.stage.dispatchEvent(new DataEvent(PlayWithYourPeas.END_SPECIAL_ITEM, {score:500, item:this} ));
		}
		
	}

}