package com.mccullick.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	* ...
	* @author Philip McCullick
	*/
	public class DisplayObjectUtils 
	{
		
		public static function getCenteredSprite(source:DisplayObject):Sprite
		{
			var sourceCentered:Sprite;
			
			sourceCentered = new Sprite();
			sourceCentered.name = source.name;
			sourceCentered.addChild(source);
			var rect:Rectangle = source.getBounds(sourceCentered);
			source.x -= rect.x + rect.width / 2;
			source.y -=  rect.y + rect.height / 2;
			
			return sourceCentered;
		}
		
		public static function getPointCenteredSprite(source:DisplayObject, point:Point):Sprite
		{
			var sourceCentered:Sprite;
			
			sourceCentered = new Sprite();
			sourceCentered.name = source.name;
			sourceCentered.addChild(source);
			var rect:Rectangle = source.getBounds(sourceCentered);
			source.x -= point.x;
			source.y -= point.y;
			
			return sourceCentered;
		}
		
		public static function resizeDisplayObject(maxWidth:Number, maxHeight:Number, dp:DisplayObject):void
		{

			var w:Number = dp.width;
			var h:Number = dp.height;

			var ratio:Number = w / h;

			w = maxWidth;
			h = Math.floor(maxWidth / ratio);
			 

			if (h > maxHeight)
			{
				h = maxHeight;
				w = Math.floor(maxHeight * ratio);
			}
			dp.width = w;
			dp.height = h;

		}
		
	}
	
}