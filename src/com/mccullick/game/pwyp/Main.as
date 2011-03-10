package com.mccullick.game.pwyp
{
	import com.mccullick.game.DetectSite;
	import com.mccullick.utils.DisplayObjectUtils;
	import com.mccullick.utils.SpriteManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import caurina.transitions.properties.ColorShortcuts;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.Security;
	/**
	 * Setup the assets and start the game
	 * @author Philip McCullick
	 */
	public class Main extends Sprite 
	{		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//init the shortcuts for caurina tweener
			ColorShortcuts.init();
			
			this.scrollRect = new Rectangle(0, 0, Settings.GAME_WIDTH, Settings.GAME_HEIGHT );
			
			//setup assets
			GameAssets.init();
			
			//start the game
			var game:PlayWithYourPeas = new PlayWithYourPeas(stage, this);
		}
		
		
	}
	
}