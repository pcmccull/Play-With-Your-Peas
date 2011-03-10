package com.mccullick.game.pwyp 
{
	import be.boulevart.labs.Collision;
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import com.mccullick.events.DataEvent;
	import com.mccullick.game.pwyp.listeners.b2PeaContactListener;
	import com.mccullick.utils.SpriteManager;
	import com.reintroducing.sound.SoundManager;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ws.tink.display.HitTest;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class GameModel 
	{
		private var _currentPea:Pea;
		private var _blocks:Array;
		private var _specialItems:Dictionary;
		private var _maxXBlocks:Number;
		private var _maxYBlocks:Number;
		private var world:b2World;
		private var worldScale:int = 30;
		private var debugDraw:b2DebugDraw;

		
		public function GameModel() 
		{
			
		}
		
		public function setupDebugDraw(debugSprite:Sprite ):void
		{			
			debugDraw = new b2DebugDraw();
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetDrawScale(worldScale);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit);
		}
		
		public function drawBox(location:Point,width:Number,height:Number, data:Object):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			
			//newBody.type=b2Body.b2_dynamicBody;
			
			
			var newBox:b2PolygonShape = new b2PolygonShape();
		
			newBox.SetAsBox(width/2/worldScale, height/2/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			
			
			var worldBody:b2Body = world.CreateBody(newBody);
			worldBody.SetUserData(data);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		}
		public function drawCircle(location:Point,radius:Number):b2Body {
			var newBody:b2BodyDef= new b2BodyDef();
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			
			newBody.type=b2Body.b2_dynamicBody;
		
			var newCircle:b2CircleShape=new b2CircleShape(radius/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.density=7;
			newFixture.friction = 10;			
			newFixture.restitution = .4;

			newFixture.shape=newCircle;
			var worldBody:b2Body = world.CreateBody(newBody);
			var massData:b2MassData = new b2MassData();
			massData.mass = 100 * 1/GameStats.getInstance().currentLevel.scale;
			
			
			
			
			
			worldBody.SetMassData(massData);
			worldBody.CreateFixture(newFixture);
			worldBody.SetAngularDamping(1);
			return worldBody;
		}

		
		public function init():void
		{
			this._blocks = new Array();
			this._specialItems = new Dictionary(true);
			this.world = new b2World(new b2Vec2(0, 9.8), true);
			var contactListener:b2ContactListener = new b2PeaContactListener();
			world.SetContactListener(contactListener);
			//		world.SetDebugDraw(debugDraw);
			
			maxXBlocks = 1/GameStats.getInstance().currentLevel.scale * Settings.PLAY_AREA_WIDTH / Settings.BLOCK_WIDTH;
			maxYBlocks = 1/GameStats.getInstance().currentLevel.scale * Settings.PLAY_AREA_HEIGHT / Settings.BLOCK_HEIGHT ;
			
			
			for (var y:Number = 0; y <= maxYBlocks; y++)
			{
				this._blocks.push({length:0, topBlock:undefined});
			}
			
			drawBox(new Point(Settings.PLAY_AREA_WIDTH / 2 - 15, 29*GameStats.getInstance().currentLevel.scale), Settings.PLAY_AREA_WIDTH, 20, {type:"floor", barrier:true});
			drawBox(new Point(-30, -Settings.PLAY_AREA_HEIGHT / 2 + 30 ), 20, Settings.GAME_HEIGHT +100 , {type:"wall", barrier:true});
			drawBox(new Point(Settings.PLAY_AREA_WIDTH + 8 , -Settings.PLAY_AREA_HEIGHT / 2 + 30), 20, Settings.GAME_HEIGHT + 100, { type:"wall", barrier:true } );
			
		}
		
		public function resetBlocks():void
		{
			for (var y:Number = 0; y <= maxYBlocks; y++)
			{
				for (var x:Number = 0; x <= maxXBlocks; x++)
				{
					if (hasBlock(x, y))
					{
						getBlock(x, y).resetFlags();
					}
				}
			}
		}
		
		public function update(dt:Number):void
		{
			try 
			{	
				if (GameStats.getInstance().currentGameSpeed.value == 1)
				{
					world.Step(1 / 60, 10, 10);
				}else
				{
					world.Step(1 / 30, 10, 10);
				}
			}catch (e:TypeError)
			{
				trace("type error caught");
			}
			world.ClearForces();
			world.DrawDebugData();
			
			if (_currentPea != null)
			{
				if (!_currentPea.usingPhysics)
				{
					_currentPea.update(dt, this);
				}
				else
				{
				
					var worldBody:b2BodyDef =  _currentPea.worldBody.GetDefinition();
					//check if the pea is at rest or if it should continue to follow the physics
					var bUpdate:Boolean = true;
					if ((_currentPea.worldBody.GetAngularVelocity() > Settings.MINIMUM_ANGULAR_VELOCITY ||
						_currentPea.worldBody.GetLinearVelocity().Length() > Settings.MINIMUM_VELOCITY))
					{						
						_currentPea.peaSleepCounter = 0;
					}else
					{
						_currentPea.peaSleepCounter++
						if (_currentPea.peaSleepCounter > 35)
						{
							bUpdate = false;						
						}
					}
					
					if (bUpdate && _currentPea.worldBody.IsAwake())
					{
						_currentPea.rotation = 180*worldBody.angle/Math.PI;
						_currentPea.x = worldBody.position.x*worldScale;
						_currentPea.y = worldBody.position.y * worldScale;
					}else
					{
						endPhysicsPea(_currentPea, _currentPea.worldBody);
					}
				}
			}
			
			if (_currentPea != null)
			{
				//check for collision with special items
				for each(var iSpecial:SpecialItem in _specialItems)
				{
					var specialSprite:Sprite = iSpecial.getSprite();
					
					
					if (specialSprite != null && specialSprite.hitTestObject(_currentPea))
					{
						if (HitTest.complexHitTestObject(specialSprite, _currentPea, specialSprite.root, 1))
						{
							iSpecial.onHit();
						}
					}
				}
			}
		}
		
		public function endPhysicsPea(pea:Pea, body:b2Body):void
		{
			var userData:Object = body.GetUserData();
			
			if (userData.blockFlag!= null)
			{
				var bOverMax:Boolean = userData.block.updateFlag(true, userData.direction );
				if (bOverMax)
				{
					pea.currentBounceBlocks = new Array();
				}
				userData.blockFlag.good.alpha = 1;
			}
			pea.rotation = 0;						
			pea.endPhysics(this);
			world.DestroyBody(body);
			
		}
		public function addPhysicsPea(pea:Pea, velocityX:Number, velocityY:Number, block:Block, scoredJump:Boolean=true):void
		{
			if (world.IsLocked())
			{
				setTimeout(function():void {
					
					addPhysicsPea(pea, velocityX, velocityY, block, scoredJump);
				},50);
				return;
			}
			pea.usingPhysics = true;
			pea.scoredJump = scoredJump;
			if (scoredJump && block != null)
				pea.scoredJump = block.isFlagMaxed(pea.getDirection());
			trace("Scoring Jump:" + pea.scoredJump);
				
			var peaBody:b2Body = drawCircle(new Point(pea.x, pea.y), Settings.modifiedPeaRadius);
			var peaMass:b2MassData = new b2MassData();
			peaBody.GetMassData(peaMass);
			peaMass.mass = Settings.PEA_MASS;		
			peaBody.SetMassData(peaMass);
			peaBody.SetUserData( { pea:pea, model:this, blockFlag:null, block:block, direction:pea.getDirection() } );
			
			peaBody.ApplyImpulse(new b2Vec2(velocityX * 100, velocityY * 100), peaBody.GetWorldCenter());
			pea.worldBody = peaBody;
			pea.peaSleepCounter = 0;
			pea.currentBounceBlocks = new Array();
			pea.switchedDirectionsDuringJump  = false;
			pea.smile();
			trace(block);
			if (scoredJump && block != null)
			{
				block.makeFixedBlock();
				
				peaBody.GetUserData().blockFlag = block.addFlag(pea.getDirection());;
			}
			
		}
		
		public function killPea(pea:Pea, showGhost:Boolean=true):void
		{
			trace("is pea alive: " + pea.alive);
			if (pea.alive)
			{
				
				
				if (pea.worldBody.GetUserData().blockFlag!= null)
				{
					pea.worldBody.GetUserData().blockFlag.bad.alpha = 1;
					pea.worldBody.GetUserData().blockFlag.good.alpha = 0;
				}
				pea.alive = false;
				pea.worldBody.SetAngularVelocity(0);
				pea.worldBody.SetLinearVelocity(new b2Vec2(0, 0));
				pea.worldBody.SetActive(false);
				pea.worldBody.SetAwake(false);				
				
				pea.alpha = 0;
				pea.visible = false;
				_currentPea = null;
				
				pea.stage.dispatchEvent(new DataEvent(PlayWithYourPeas.PEA_KILLED_EVENT, { pea:pea } ));
				GameView(pea.parent.parent).killPea(pea, showGhost);
				var count:Number = 0;
				//wait one frame to remove the body from the world
				var removePeaBody:Function = function(evt:Event):void
					{		
						count++
						if (count > 4)
						{
							pea.stage.removeEventListener(Event.ENTER_FRAME, removePeaBody);
							world.DestroyBody(pea.worldBody);
					
						}
					}
				pea.stage.addEventListener(Event.ENTER_FRAME, removePeaBody);
			}
		}
		
		public function trappedPea(pea:Pea):void
		{
			//Say it's a trap
			SoundManager.getInstance().playSound("fxItsATrap", 1*Settings.SOUND_VOLUME, 0, 0, "fx");
			pea.say("AlertTrap");
			killPea(pea);
		}
		
		
		public function setTopBlock(block:Block, x:Number, y:Number):void
		{
			//if there is already a topBlock for this row then just make this the top block
			
			var bFoundTopBlock:Boolean = false;
			if (blocks[y].topBlock != undefined)
			{
				bFoundTopBlock = true;
				block.parent.setChildIndex(block, block.parent.getChildIndex(blocks[y].topBlock) + 1);
				
			}else {				
				var searchY:Number = y - 1;
				
				while (!bFoundTopBlock && searchY >= 0)
				{
					if (blocks[searchY].topBlock != undefined)
					{
						var foundBlock:Block = blocks[searchY].topBlock;
						block.parent.setChildIndex(block, foundBlock.parent.getChildIndex(foundBlock) + 1);
						bFoundTopBlock = true;
						
					}else
					{
						searchY --;
					}
					
				}
			}
			if (!bFoundTopBlock)
					{
						block.parent.setChildIndex(block, 0);
					}
			blocks[y].topBlock = block;
		}
		
		public function isValidBlockPoint(x:Number, y:Number):Boolean
		{
			
			var stats:GameStats = GameStats.getInstance()
			var blockBelow:Block = getBlock(x, y - 1);
			
			if (blockBelow != null && blockBelow.allowBlockAbove == false)
			{
				//this is a block above the exit
				return false;
			}else if (x > maxXBlocks || x < 0 ||
					y > maxYBlocks || y < 0)
			{
				return false;
			}else
			{
				return !hasBlock(x, y);
			}
		}
		
		public function hasBlockGamePoint(x:Number, y:Number, direction:Number = NaN):Boolean
		{
			var blockPoint:Point = convertGameToBlockCoord(x, y);
			
			
			return hasBlock(blockPoint.x, blockPoint.y, direction);
			
		}
		
		public function hasBlock(x:Number, y:Number, direction:Number=NaN):Boolean
		{ 
			
			if (isNaN(direction))
			{
				return getBlock(x, y) != null  && getBlock(x, y).title != Settings.blocks.entranceBlock.title;
			}else if (direction == Settings.LEFT)
			{
				return getBlock(x-1,y)  != null  && getBlock(x, y).title != Settings.blocks.entranceBlock.title;
			}else if (direction == Settings.RIGHT)
			{
				return getBlock(x+1,y)  != null  && getBlock(x, y).title != Settings.blocks.entranceBlock.title;
			}
			return false;
			
		}
		
		public function getBlock(x:Number, y:Number):Block
		{ 
			if (x >= 0 && x <= maxXBlocks &&
				y >= 0 && y <= maxYBlocks)
				return blocks[y][x];
			else	
				return null;
		}
		
	
		private var addingBlocks:Object = new Object();
		public function addBlock(block:Block, x:Number, y:Number):Boolean
		{
			//if the x or y are outside the game play area then return false
			
			if (!isValidBlockPoint(x, y)) return false;
			
			var addingIndex:Number = x + y * maxXBlocks;
			
			if (addingBlocks[addingIndex] != undefined)
				return false;
			else
				addingBlocks[addingIndex] = true;
			var timer:Timer = new Timer(Settings.ADD_BLOCK_DELAY*1000, 1);
			
			var onAddBlock:Function = function(evt:Event):void
				{
					var peaBlock:Point;
					if (_currentPea != null)
						peaBlock = convertGameToBlockCoord(_currentPea.x, _currentPea.y);
						
					if (_currentPea != null && peaBlock.x == x && peaBlock.y == y)
					{
					
						timer = new Timer(100, 1);
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, onAddBlock);
					 	timer.start();
					}else
					{		
						blocks[y][x] = block;
						blocks[y].length++;
						addingBlocks[addingIndex] = undefined;
				
						var gamePoint:Point = convertBlockToGameCoord(x, y);
						gamePoint.y -= 6;
						var boxBody:b2Body = block.setupB2Body(world, worldScale , gamePoint, Settings.modifiedBlockWidth ,	Settings.modifiedBlockHeight);
						if (boxBody != null)
						{
							boxBody.SetUserData( { model:this, block:block } );
							block.worldBody = boxBody;
							block.setBlockXY(x, y);
						}
					}
				};
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onAddBlock);
			timer.start();
			return true;
		}
		
		/**
		 * Removes a block and sets the topBlock for that row if the topBlock is removed.
		 * @param	x
		 * @param	y
		 * @return
		 */
		public function removeBlock(x:Number, y:Number):Block
		{
			var removedBlock:Block = blocks[y][x];
			if (world.IsLocked())
			{
				setTimeout(function():void {
					
					removeBlock(x, y)
				},50);
				return removedBlock;
			}
			var parentSprite:DisplayObjectContainer = removedBlock.parent;
			
			//if this is a top block find the new top block
			if (blocks[y].topBlock == removedBlock && blocks[y].length > 1)
			{
				var newTopBlock:Block = null;
				var topLayerIndex:Number = 0;
				for (var i:Object in blocks[y])
				{
					if (blocks[y][i] is Block && blocks[y][i] != removedBlock)
					{
						if (blocks[y][i].parent == parentSprite)
						{
							var blockIndex:Number = parentSprite.getChildIndex(blocks[y][i]);
							if (blockIndex > topLayerIndex)
							{
								newTopBlock = blocks[y][i];
								topLayerIndex = blockIndex;
							}						
						}
					}
				}
				blocks[y].topBlock = newTopBlock;
			}else if (blocks[y].topBlock == removedBlock)
			{
				//there are no other blocks on this row so set topBlock to undefined
				blocks[y].topBlock = undefined;
			}
			//remove the block from this row
			blocks[y][x] = undefined;
			blocks[y].length --;
		
			world.DestroyBody(removedBlock.worldBody);
			return removedBlock;
		}
		
		public function addSpecialItem(item:SpecialItem):void
		{
			this._specialItems[item] = item; 
		}
		
		public function removeSpecialItem(item:SpecialItem):void
		{
			delete this._specialItems[item];
		}
		public function removeAllSpecialItems():void
		{
			for (var item:String in this._specialItems)
			{
				removeSpecialItem(this._specialItems[item]);				
			}
		}
		
		public function cleanup():void
		{
			if (world != null)
			{
				addingBlocks = new Object();
				world = null;
				_currentPea = null;
				blocks = null
				_specialItems = null;
			}
		}
		
		public function addPea(pea:Pea):void
		{
			_currentPea = pea;
		}
		
		
		public function get blocks():Array { return _blocks; }
		
		public function set blocks(value:Array):void 
		{
			_blocks = value;
		}
		
		public function get maxXBlocks():Number { return _maxXBlocks; }
		
		public function set maxXBlocks(value:Number):void 
		{
			_maxXBlocks = Math.floor(value);
		}
		
		public function get maxYBlocks():Number { return _maxYBlocks; }
		
		public function set maxYBlocks(value:Number):void 
		{
			_maxYBlocks =  Math.floor(value);
		}
		
		public static function convertStageToGameCoord(x:Number, y:Number):Point
		{
			return new Point((x - Settings.GAME_VIEW_OFFSET_X), 
							 (y - Settings.modifiedGameViewOffsetY));
		}
		
		public static function convertGameToBlockCoord(x:Number, y:Number):Point
		{
			return new Point(Math.round(x / (Settings.BLOCK_WIDTH * GameStats.getInstance().currentLevel.scale)),
							 Math.round(-y / (Settings.BLOCK_HEIGHT * GameStats.getInstance().currentLevel.scale)));
		}
		public static function convertBlockToGameCoord(x:Number, y:Number):Point
		{
			return new Point(x * Settings.BLOCK_WIDTH*GameStats.getInstance().currentLevel.scale, 
							-y * Settings.BLOCK_HEIGHT*GameStats.getInstance().currentLevel.scale);
		}
		
		
		
	}
	
}