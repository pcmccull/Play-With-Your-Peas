package com.mccullick.game 
{
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class DetectSite 
	{
			
		public static function isKongregate(root:DisplayObject):Boolean
		{
			return detectSite("kongregate.com", root);
		}
		
		public static function isMindjolt(root:DisplayObject):Boolean
		{
			return detectSite("mindjolt.com",root);
		}
		
		public static function isGameLand(root:DisplayObject):Boolean
		{
			return detectSite("gameland.com",root);
		}
		
		public static function isGameShed(root:DisplayObject):Boolean
		{
			return detectSite("gameshed.com",root);
		}
		public static function isNonoba(root:DisplayObject):Boolean
		{
			return detectSite("nonoba.com",root);
		}
		
		public static function detectSite(url:String, root:DisplayObject):Boolean
		{
			var domain:String = root.loaderInfo.url.split("/")[2];
			return (domain.indexOf(url) == (domain.length - url.length));
		}
		
	}
	
}
