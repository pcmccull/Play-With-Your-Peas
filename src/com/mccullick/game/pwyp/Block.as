package com.mccullick.game.pwyp 
{
	import Box2D.Dynamics.b2Body;
	import caurina.transitions.Tweener;
	import com.mccullick.utils.SpriteManager;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;

	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class Block extends Sprite
	{
		private var _title:String;
		private var  _blockId:String;
		public var  setupB2Body:Function;
		private var _worldBody:b2Body;
		private var _sprite:DisplayObject;
		private var _walkSpeed:Number;
		private var _climbSpeed:Number;
		public var _fixedBlock:Boolean;
		private var jumpsRight:Number = 0;
		private var jumpsLeft:Number = 0;
		private var _blockX:Number;
		private var _blockY:Number;
		private var flagPoleRight:Sprite;
		private var _allowBlockAbove:Boolean;
		private var _completelyFixed:Boolean;
		private var flagPoleLeft:Sprite;
		public function Block(title:String, blockId:String, setupB2Body:Function, walkSpeed:Number=1, climbSpeed:Number=.6, allowBlockAbove:Boolean = true) 
		{
			this.allowBlockAbove = allowBlockAbove;
			this._title = title;
			this._blockId = blockId;
			this.setupB2Body = setupB2Body;			
			this._walkSpeed = walkSpeed;
			this._climbSpeed = climbSpeed;
			this._fixedBlock = false;
			this.completelyFixed = !allowBlockAbove;
		}
		public function setBlockXY(blockX:Number, blockY:Number):void
		{
			this.blockX = blockX;
			this.blockY = blockY;
		}
		
		public function makeFixedBlock():void
		{
			fixedBlock = true;
			var matrix:Array = new Array();
			matrix=matrix.concat([0.6,0.5,0.5,0,0]);// red
			matrix=matrix.concat([0.5,0.55,0.5,0,0]);// green
			matrix=matrix.concat([0.5,0.5,0.7,0,0]);// blue
			matrix=matrix.concat([0,0,0,1,0]);// alpha
			var bwFilter:ColorMatrixFilter=new ColorMatrixFilter(matrix);			

			this.sprite.filters = [bwFilter];
		}
		public function resetFlags():void
		{
			jumpsLeft = 0;
			jumpsRight = 0;
			if (!completelyFixed)
			{
				fixedBlock = false;
				allowBlockAbove = true;
			}
			this.sprite.filters = [];
			if (flagPoleLeft != null)
			{
				this.removeChild(flagPoleLeft);
				flagPoleLeft = null;
			}
			if (flagPoleRight != null)
			{
				this.removeChild(flagPoleRight);
				flagPoleRight = null;
			}
			
		}
		public function addFlag(direction:Number):Sprite
		{
			this.allowBlockAbove = false;
			if (direction == Settings.LEFT )
			{
				if (this.flagPoleLeft == null)
				{
					this.jumpsLeft = 0;
					this.flagPoleLeft = SpriteManager.getSprite("FlagPole") as Sprite;	
					this.addChild(flagPoleLeft);
					this.flagPoleLeft.y = -Settings.BLOCK_HEIGHT - 5;
					this.flagPoleLeft.x = 16;
					if (title == Settings.blocks.leftRamp.title )
					{
						this.flagPoleLeft.y = -16;
					}
				}				
					
				return flagPoleLeft;
			}else
			{
				if (this.flagPoleRight == null)
				{
					this.jumpsRight = 0;
					this.flagPoleRight = SpriteManager.getSprite("FlagPole") as Sprite;	
					this.addChild(flagPoleRight);
					this.flagPoleRight.y = -Settings.BLOCK_HEIGHT - 5;
					this.flagPoleRight.x = Settings.BLOCK_WIDTH - 18;
					this.flagPoleRight.getChildByName("good").scaleX = -1;
					this.flagPoleRight.getChildByName("bad").scaleX = -1;
					if (title == Settings.blocks.rightRamp.title  )
					{
						this.flagPoleRight.y =-16;
					}
				}
				
				return flagPoleRight;
			}
		}
		
		/**
		 * Get whether this flag is maxed
		 * @param	direction
		 * @return Boolean
		 */
		public function isFlagMaxed(direction:Number):Boolean
		{
			if (direction == Settings.LEFT)
			{
				return jumpsLeft < Settings.MAX_SCORED_JUMPS_PER_BLOCK;
			}else
			{
				return jumpsRight < Settings.MAX_SCORED_JUMPS_PER_BLOCK;
			}
		}
		
		public function updateFlag(peaSurvived:Boolean, direction:Number):Boolean
		{
			var bOverMax:Boolean = true;
			if (peaSurvived)
			{
				if (direction == Settings.LEFT )
				{
					jumpsLeft++;
					if (jumpsLeft <= Settings.MAX_SCORED_JUMPS_PER_BLOCK)
					{
						bOverMax = false;
						this.flagPoleLeft.getChildByName("good").y = -(Settings.FLAGPOLE_HEIGHT - Settings.FLAG_HEIGHT) / 
																		Settings.MAX_SCORED_JUMPS_PER_BLOCK * jumpsLeft;
						if (jumpsLeft == Settings.MAX_SCORED_JUMPS_PER_BLOCK)
							makeFlagMaxed(direction);
					}
				}else
				{
					jumpsRight++;
					if (jumpsRight <= Settings.MAX_SCORED_JUMPS_PER_BLOCK)
					{
						bOverMax = false;
						this.flagPoleRight.getChildByName("good").y = -(Settings.FLAGPOLE_HEIGHT - Settings.FLAG_HEIGHT) / 
																			Settings.MAX_SCORED_JUMPS_PER_BLOCK * jumpsRight;
						if (jumpsRight == Settings.MAX_SCORED_JUMPS_PER_BLOCK)
							makeFlagMaxed(direction);
					
					}
				}
			}
			
			return bOverMax;
		}
		
		public function makeFlagMaxed(direction:Number):void
		{
			var matrix:Array = new Array();
			matrix=matrix.concat([0.5,0.5,0.5,0,0]);// red
			matrix=matrix.concat([0.5,0.5,0.5,0,0]);// green
			matrix=matrix.concat([0.5,0.5,0.5,0,0]);// blue
			matrix=matrix.concat([0,0,0,1,0]);// alpha
			var bwFilter:ColorMatrixFilter=new ColorMatrixFilter(matrix);			
			if (direction == Settings.LEFT )
			{
				this.flagPoleLeft.filters = [bwFilter];
			}else
			{
				this.flagPoleRight.filters = [bwFilter];
			}
		}
		
		public function showWaterSplashAnimation():void
		{
			
		
		}
		
		public function get title():String { return _title; }
		public function set title(_title:String):void { this._title = _title; }
		public function get blockId():String { return _blockId; }
		
		public function get sprite():DisplayObject { return _sprite; }
		
		public function set sprite(value:DisplayObject):void 
		{
			
			_sprite = value;
			this.addChild(sprite);
		}
		
		public function get walkSpeed():Number { return _walkSpeed; }
		
		public function set walkSpeed(value:Number):void 
		{
			_walkSpeed = value;
		}
		
		public function get climbSpeed():Number { return _climbSpeed; }
		
		public function set climbSpeed(value:Number):void 
		{
			_climbSpeed = value;
		}
		
		public function get worldBody():b2Body { return _worldBody; }
		
		public function set worldBody(value:b2Body):void 
		{
			_worldBody = value;
		}
		
		public function get fixedBlock():Boolean { return _fixedBlock; }
		
		public function set fixedBlock(value:Boolean):void 
		{
			_fixedBlock = value;
		}
		
		public function get blockX():Number { return _blockX; }
		
		public function set blockX(value:Number):void 
		{
			_blockX = value;
		}
		
		public function get blockY():Number { return _blockY; }
		
		public function set blockY(value:Number):void 
		{
			_blockY = value;
		}
		
		public function get allowBlockAbove():Boolean { return _allowBlockAbove; }
		
		public function set allowBlockAbove(value:Boolean):void 
		{
			_allowBlockAbove = value;
		}
		
		public function get completelyFixed():Boolean { return _completelyFixed; }
		
		public function set completelyFixed(value:Boolean):void 
		{
			_completelyFixed = value;
		}
		public override function toString():String
		{
			return "class Block [blockId:" + blockId + " sprite:" + sprite +"]"; 
		}
		public function cloneWithLocation(x:Number, y:Number):Block
		{
			var block:Block = clone();
			block._blockX = x;
			block._blockY = y;
			
			return block;
		}
		public function clone():Block
		{
			return new Block(title, blockId, setupB2Body, walkSpeed, climbSpeed, allowBlockAbove);			
		}
		
		
		
		
		
	}
	
}