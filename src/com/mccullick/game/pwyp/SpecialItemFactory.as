package com.mccullick.game.pwyp 
{
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class SpecialItemFactory
	{
		private static var instance:SpecialItemFactory;
		public function SpecialItemFactory(key:SingletonKey) 
		{
			
		}
		
		public static function getInstance():SpecialItemFactory 
		{
			if (instance == null)
				instance = new SpecialItemFactory(new SingletonKey());
			return instance;
			
		}
		
		public function createItem(itemType:String):SpecialItem
		{
			switch (itemType)
			{
				case "coin":
					return new CoinSpecialItem();
					break;
				default:
					return null;
			}
		
		}
		
	}

}

class SingletonKey {}