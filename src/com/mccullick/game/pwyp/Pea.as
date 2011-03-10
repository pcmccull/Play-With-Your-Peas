package com.mccullick.game.pwyp 
{
	import Box2D.Dynamics.b2Body;
	import caurina.transitions.Tweener;
	import com.mccullick.events.DataEvent;
	import com.mccullick.pwyp.assets.PeaStandard;
	import com.mccullick.utils.SpriteManager;
	import com.reintroducing.sound.SoundManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import com.mccullick.logger.Logger;
	import flash.utils.Timer;

	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class Pea extends Sprite
	{	
		
		private var moveState:Function;		
		private var calculateNextGoal:Function;
		private var _currentBlock:Point;
		private var goal:Point;
		private var speed:Number;
		private var direction:Number;
		private var directionY:Number;
		private var moveStateStep:String;
		private var _usingPhysics:Boolean;
		private var _worldBody:b2Body;
		private var _peaSleepCounter:Number;
		private var _alive:Boolean;
		private var logger:Logger = new Logger("Pea", true);
		public var mc:PeaStandard;
		private var lastBlink:Number;
		private var nextBlink:Number;
		private var _personalScore:Number;
		
		public var bandanaLevel:Number = 0;
		
		private var _gapJump:Boolean
		private var _currentBounceBlocks:Array;
		private var _switchedDirectionsDuringJump:Boolean;
		
		private var _scoredJump:Boolean = true;
		
		public function Pea(x:Number, y:Number) 
		{
			
			this.mc = new PeaStandard();
			this.lastBlink = 0;
			this.nextBlink = 800 + Math.random() * 1000;
			this.mc.blinkLeft.addFrameScript(0, function():void { MovieClip(mc.blinkLeft).stop(); } );
			this.mc.blinkLeft.gotoAndStop(0);
			this.mc.blinkRight.addFrameScript(0, function():void { MovieClip(mc.blinkRight).stop(); } );
			this.mc.blinkRight.gotoAndStop(0);
			this.addChild(mc);			
			this.alive = true;
			this.speed = Settings.PEA_SPEED;
			this.direction = 1;		
			
			this.currentBlock = new Point(x, y);
		
			this.x = GameModel.convertBlockToGameCoord(x, y).x;
			this.y = GameModel.convertBlockToGameCoord(x, y).y;
			this.goal = new Point(this.x, this.y);
			this.mc.blinkLeft.alpha = 1;
			this.mc.blinkRight.alpha = 1;
			this.mc.bandana.visible = false;
			this.mc.bandana.alpha = 1;
			//this.mc.bandana.getChildByName("bandColor")
			
			this.directionY = 1;
			startWaiting();
			this.moveStateStep = "";
			this.clickedContinue = true;
			this.personalScore = 0;
			this.mouseEnabled = false
		}
		private function waiting(dt:Number):Number
		{
			return 0;
		}
		private function calculateWaitingGoal(model:GameModel):void
		{
			
		}
		public function startWaiting():void
		{
			this.moveState = waiting;
			this.calculateNextGoal = calculateWaitingGoal;
		}
		private var clickedContinue:Boolean;
		public function update(dt:Number, model:GameModel, count:Number=0):void
		{			
			frameCount++;
			
			var leftOverTime:Number = moveState(dt);
			
			//if there is time left over from the last move then the pea reached its goal and has time for another move
			if (leftOverTime > 0)
			{
				logger.log(":::LeftOver:: " + leftOverTime);
				if ((clickedContinue) && !usingPhysics)
				{
					calculateNextGoal(model);
					
					//keep the number of updates per frame down 
					if (count > 2) return;
				
					update(leftOverTime, model, ++count);
					
				}
			}
			
			//control random pea animations
			lastBlink += dt;			
			if (lastBlink > nextBlink)
			{
				this.nextBlink = 800 + Math.random() * 1000;
				this.lastBlink = 0;
				
				if (Math.random() > .5)
				{
					this.mc.blinkLeft.gotoAndPlay(1);
				}else
				{
					this.mc.blinkRight.gotoAndPlay(1);
				}
			}
		}
		public function smile():void
		{
			this.mc.smile.alpha = 1;			
		}
		private var painTimer:Timer = null;
		public function showPain():void
		{
			this.mc.smile.alpha = 0;
			this.mc.leftEye.alpha = 0;
			this.mc.rightEye.alpha = 0;
			this.mc.pain.alpha = 1;
		
				
			if (painTimer != null)
			{
				stopPainTimer(new Event(TimerEvent.TIMER));
			}
			painTimer = new Timer(500, 1);
			trace("start pain timer" + painTimer.currentCount);
			painTimer.addEventListener(TimerEvent.TIMER, function(evt:Event):void { stopPainTimer(new Event(TimerEvent.TIMER)); mc.smile.alpha = 1;} );
			painTimer.start();
		}
		public function stopPainTimer(evt:Event):void
		{
			mc.leftEye.alpha = 1;
			mc.rightEye.alpha = 1;
			mc.pain.alpha = 0;
			mc.smile.alpha = 0;
			painTimer.stop();
			painTimer = null;
		}
		public function endPhysics(model:GameModel):void
		{
			gapJump = false;
			var lastJumpScore:Number = scoreJump();
			this.currentBounceBlocks = new Array();
			this.mc.smile.alpha = 0;	
			if (painTimer != null)
			{
				stopPainTimer(new Event(TimerEvent.TIMER));
			}
			usingPhysics = false;
			currentBlock = GameModel.convertGameToBlockCoord(this.x, this.y);
			this.moveState = walking;	
			this.calculateNextGoal = calculateWalkingGoal;
			this.goal = GameModel.convertBlockToGameCoord(currentBlock.x, currentBlock.y);
			if (lastJumpScore > Settings.MINIMUM_NINJA_JUMP_SCORE)
			{
				var ninjaAlert:DisplayObject = SpriteManager.getSprite("AlertNinja");
				this.addChild(ninjaAlert);
				var thisObj:Pea = this;
				Tweener.addTween(ninjaAlert, { alpha:0, delay:1, time:1, onComplete:function():void
						{
							thisObj.removeChild(ninjaAlert);
				}});
			}
			//clickedContinue = false;
			
			//TODO make the pea walk to the edge of the current block they landed on, currently peas are walking in mid air
			var blockBelow:Block = model.getBlock(currentBlock.x, currentBlock.y - 1);
			if (( !model.hasBlock(currentBlock.x, currentBlock.y)) && (currentBlock.y == 0 || blockBelow == null ||(blockBelow.title != Settings.blocks.leftRamp.title &&
					blockBelow.title != Settings.blocks.rightRamp.title)))
			{
				goal.x += Settings.modifiedPeaRadius * direction; 
				
			}else
			{
				this.calculateNextGoal = calculateRampGoal;
				
			}
			
			if (blockBelow != null && blockBelow.title == Settings.blocks.spikey.title)
			{
				model.killPea(this);
				
			}
			//Also make sure the pea is on the ground/block below it.
			
		}
		
		public function say(str:String):void
		{			
			var trapAlert:DisplayObject = SpriteManager.getSprite(str);
			trapAlert.x = this.x;
			trapAlert.y = this.y;
			this.parent.addChild(trapAlert);
			var thisObj:Pea = this;
			Tweener.addTween(trapAlert, { alpha:0, delay:2, time:1, onComplete:function():void
					{
						if (trapAlert.parent  != null)
							trapAlert.parent.removeChild(trapAlert);
					}});
		}
		
		
		
		public function startPhysics(model:GameModel):void
		{
			model.addPhysicsPea(this, 0, 0, null, false);
			
		}
		
		private function beginNinjaJump(model:GameModel):void
		{
			this.y -= 3;
			var jumpBlock:Block = model.getBlock(currentBlock.x, currentBlock.y - 1);
			if (jumpBlock == null)
				jumpBlock = model.getBlock(currentBlock.x - direction, currentBlock.y);
				
			model.addPhysicsPea(this, Settings.PEA_JUMP_SPEED_X * direction*GameStats.getInstance().currentLevel.scale, -Settings.PEA_JUMP_SPEED_Y, jumpBlock, jumpBlock != null);
			addBounceBlock(jumpBlock);
			usingPhysics = true;
		}
		private function beginWallNinjaJump(model:GameModel):void
		{
			currentBlock = GameModel.convertGameToBlockCoord(this.x, this.y);
			
			var jumpBlock:Block = model.getBlock(currentBlock.x + direction, currentBlock.y);
			
			model.addPhysicsPea(this, Settings.PEA_JUMP_SPEED_X * direction * 3*GameStats.getInstance().currentLevel.scale, .1, jumpBlock, true);				
			addBounceBlock(jumpBlock);
			usingPhysics = true;
			direction *= -1;
		}
		private function beginGapJump(model:GameModel):void
		{
			var jumpBlock:Block = model.getBlock(currentBlock.x, currentBlock.y - 1);
			if (jumpBlock == null)
				jumpBlock = model.getBlock(currentBlock.x, currentBlock.y);
			//Jump across gap
			this.y -= 3;
			model.addPhysicsPea(this, Settings.PEA_JUMP_SPEED_X * direction * GameStats.getInstance().currentLevel.scale, -Settings.PEA_JUMP_SPEED_Y * .9, jumpBlock, false);			
			usingPhysics = true;
			gapJump = true;
		}
		public function switchDirections():void
		{
			direction *= -1;
			speed *= -1;
		}
		private var frameCount:Number = 0;
		private function calculateWalkingGoal(model:GameModel):void
		{
			logger.log("-------------------------------------------------------");
			
			this.moveState = walking;			
			currentBlock = GameModel.convertGameToBlockCoord(this.x, this.y);
			var nextX:Number = (currentBlock.x + direction);
			
			//if you have reached the edge of the screen then turn around
			logger.log("NextX:  " + nextX + " " + model.maxXBlocks)
			if (this.x > model.maxXBlocks * Settings.modifiedBlockWidth && direction == 1)
			{
				currentBlock.x += direction;
				direction = -1;
				speed *= -1;
				nextX = currentBlock.x + direction;
				
			}
			if (nextX > model.maxXBlocks+1 || nextX < 0)
			{
				currentBlock.x += direction;
				logger.log( "<<<<<<<<< TURN AROUND >>>>>>>>>>");
				direction *= -1;
				speed *= -1;
				nextX = currentBlock.x + direction;
			}
			
			if (currentBlock.x < 0)
				currentBlock.x = 0;
			
			//logger.log(model.maxXBlocks + " " + currentBlock.x);
			/*if (frameCount % 80 == 0)
			{
				logger.log(currentBlock);
			}*/
			//logger.log(model.getBlock(currentBlock.x, currentBlock.y));
			var nextBlock:Block
			
			//test for walking on special blocks
			
			if (model.hasBlock(currentBlock.x, currentBlock.y - 1) )
			{
				var walkingBlock:Block = model.getBlock(currentBlock.x, currentBlock.y - 1);
				if (walkingBlock.title == Settings.blocks.exit.title)
				{
					calculateNextGoal = calculateLevelCompleted;
					return;	
				}else if (walkingBlock.title == Settings.blocks.spikey.title)
				{
					model.killPea(this);
					return;
				}
			}
			
			
			logger.log(currentBlock);
			logger.log(direction);
			logger.log("movingto: " + nextX + "," + currentBlock.y);
			logger.log(model.hasBlock(nextX, currentBlock.y));
			
			if (currentBlock.y < 0)
				currentBlock.y = 0;
			//check if there is a block in the way or above
			if (!model.hasBlock(nextX, currentBlock.y) && 
				!(model.hasBlock(currentBlock.x + direction, currentBlock.y + 1) && !model.hasBlock(currentBlock.x, currentBlock.y + 1) && 
					(currentBlock.y == 0 ||model.hasBlock(currentBlock.x, currentBlock.y-1))))				
			{	
				//check if there is something to walk on				
				if (currentBlock.y == 0 || model.hasBlock(nextX, currentBlock.y - 1))
				{
					nextBlock = model.getBlock(nextX, currentBlock.y-1);
					//check if the next block below is a slope
					if (nextBlock != null && ((nextBlock.title == Settings.blocks.leftRamp.title) ||
					(nextBlock.title == Settings.blocks.rightRamp.title)))
					{
						if (nextBlock.title == Settings.blocks.leftRamp.title && direction == Settings.LEFT)
						{
							
							//start climbing down left ramp slope
							goal = GameModel.convertBlockToGameCoord(nextX, currentBlock.y);				
							goal.y = y;
							nextBlock = model.getBlock(currentBlock.x, currentBlock.y);
							if (nextBlock == null)
								speed = Settings.PEA_SPEED*direction;
							else
								speed = nextBlock.walkSpeed * Settings.PEA_SPEED * direction;
							
							goal.x -= Settings.modifiedPeaRadius *2* direction+6; 				
							
							calculateNextGoal = calculateRampDownGoal;	
						}else if(nextBlock.title == Settings.blocks.rightRamp.title && direction == Settings.RIGHT)
						{
							//start climbing down right ramp slope
							goal = GameModel.convertBlockToGameCoord(nextX, currentBlock.y);				
							goal.y = y;
							nextBlock = model.getBlock(currentBlock.x, currentBlock.y);
							if (nextBlock == null)
								speed = Settings.PEA_SPEED*direction;
							else
								speed = nextBlock.walkSpeed * Settings.PEA_SPEED * direction;
							
							goal.x -= Settings.modifiedPeaRadius * 2 * direction -6;
											
							calculateNextGoal = calculateRampDownGoal;	
						}else
						{
							
							//Begin ninja jump sequence
							beginNinjaJump(model);
						}
					}else
					{
						
						//normal block top so continue walking
						var currentWalkingBlock:Block = model.getBlock(currentBlock.x, currentBlock.y - 1);				
						
						goal = GameModel.convertBlockToGameCoord(nextX, currentBlock.y);				
						goal.y = y;
						
						if (currentWalkingBlock == null)
							speed = Settings.PEA_SPEED*direction;
						else
							speed = currentWalkingBlock.walkSpeed * Settings.PEA_SPEED * direction;
						
						goal.x += Settings.modifiedPeaRadius * direction; 		
					
						if (nextBlock != null)
						{
							if (nextBlock.title == Settings.blocks.exit.title)
							{
								goal.x -= Settings.modifiedPeaRadius * direction; 
								calculateNextGoal = calculateLevelCompleted;
							}else if (nextBlock.title == Settings.blocks.spikey.title)
							{
								goal.x -= Settings.modifiedPeaRadius * direction*1.5; 
								
							}
						}
					}
				//check if there is a block to jump across to
				}else if (false && (model.hasBlock(currentBlock.x + (direction * 2), currentBlock.y - 1) && 
						!model.hasBlock(currentBlock.x + (direction * 2), currentBlock.y) && 
						!(model.getBlock(currentBlock.x + (direction * 2), currentBlock.y - 1).title == Settings.blocks.rightRamp.title && direction == Settings.LEFT) &&
						!(model.getBlock(currentBlock.x + (direction * 2), currentBlock.y - 1).title == Settings.blocks.leftRamp.title && direction == Settings.RIGHT)
						))
				{
					//Jump across gap
					beginGapJump(model);
				}else
				{
					//Begin ninja jump sequence					
					beginNinjaJump(model);
				}
			//check if there is a block to start climbing or sliding	
			}else if (model.hasBlock(nextX, currentBlock.y))
			{
				//transition to climbing
				logger.log("has block at same level");
				
				nextBlock = model.getBlock(nextX, currentBlock.y);
				
				
				logger.log("does not have block above");
			
				if ((nextBlock.title == Settings.blocks.exit.title 	||
					nextBlock.title == Settings.blocks.spikey.title 	||
					nextBlock.title == Settings.blocks.standard.title || 
					nextBlock.title == Settings.blocks.gel.title || 
					nextBlock.title == Settings.blocks.spring.title ||
					(nextBlock.title == Settings.blocks.leftRamp.title && direction == Settings.LEFT) ||
					(nextBlock.title == Settings.blocks.topLeftRamp.title && direction == Settings.LEFT) ||
					(nextBlock.title == Settings.blocks.rightRamp.title && direction == Settings.RIGHT)||
					(nextBlock.title == Settings.blocks.topRightRamp.title && direction == Settings.RIGHT)) )
				{
					logger.log("start climb block");
					moveStateStep = "";
					goal = GameModel.convertBlockToGameCoord(nextX, currentBlock.y);				
					goal.y = y;
					goal.x -= Settings.modifiedPeaRadius*3 * direction; 
					calculateNextGoal = calculateClimbingGoal;	
					
				}else if (nextBlock.title == Settings.blocks.leftRamp.title && !model.hasBlock(currentBlock.x+direction, currentBlock.y + 1) && !model.hasBlock(currentBlock.x, currentBlock.y + 1))
				{
					
					logger.log("start left ramp");
					//start climbing left ramp slope
					goal = GameModel.convertBlockToGameCoord(nextX, currentBlock.y);				
					goal.y = y;
					nextBlock = model.getBlock(currentBlock.x, currentBlock.y);
					if (nextBlock == null)
						speed = Settings.PEA_SPEED*direction;
					else
						speed = nextBlock.walkSpeed * Settings.PEA_SPEED * direction;
					
					goal.x -= Settings.modifiedPeaRadius *2* direction+6; 				
					currentBlock.x += direction;
					calculateNextGoal = calculateRampGoal;	
				}else if (nextBlock.title == Settings.blocks.rightRamp.title && !model.hasBlock(currentBlock.x+direction, currentBlock.y + 1) && !model.hasBlock(currentBlock.x, currentBlock.y + 1))
				{
					
					logger.log("start right ramp");
					//start climbing right ramp slope
					goal = GameModel.convertBlockToGameCoord(nextX, currentBlock.y);				
					goal.y = y;
					nextBlock = model.getBlock(currentBlock.x, currentBlock.y);
					if (nextBlock == null)
						speed = Settings.PEA_SPEED*direction;
					else
						speed = nextBlock.walkSpeed * Settings.PEA_SPEED * direction;
					
					goal.x -= Settings.modifiedPeaRadius * 2 * direction -6;
									
					currentBlock.x += direction;
					calculateNextGoal = calculateRampGoal;	
				}else
				{
					logger.log("has block above");
					//block above blocking the climb, turn around
					direction *= -1;
					speed *= -1;
				}
			//check if there is a block to jump up to	
			}else if (model.hasBlock(currentBlock.x+direction, currentBlock.y+1) && !model.hasBlock(currentBlock.x, currentBlock.y+1))
			{
				
				logger.log("jumping up to block");
				goal = GameModel.convertBlockToGameCoord(currentBlock.x+direction, currentBlock.y+1);
				moveState = climbing;	
				speed = Settings.PEA_SPEED * 2;
				calculateNextGoal = calculateClimbingGoal;	
			}else
			{
				logger.log("ERROR: no move!");
			}
			
			
		}
		
		private function calculateClimbingGoal(model:GameModel):void
		{

			this.moveState = climbing;
			var nextBlock:Block;
			currentBlock = GameModel.convertGameToBlockCoord(this.x, this.y);
			logger.log("state step: " + moveStateStep);
			//if there is no block above you and there is a block next to you then continue climbing
			if (moveStateStep != "")
			{ 
				
				if (moveStateStep == "finishClimbToWalk")
				{			
					
					goal = GameModel.convertBlockToGameCoord(currentBlock.x, currentBlock.y);
					goal.x += Settings.modifiedPeaRadius * 2*direction;
					currentBlock.x += direction;
					
					calculateNextGoal = calculateWalkingGoal;					
					
				}else if (moveStateStep == "finishClimbToSlide")
				{
					logger.log("finished ClimbtoSlide");
					//start climbing left ramp slope
					goal = GameModel.convertBlockToGameCoord(currentBlock.x + direction, currentBlock.y);				
					goal.y = y;
					nextBlock = model.getBlock(currentBlock.x, currentBlock.y);
					if (nextBlock == null)
						speed = Settings.PEA_SPEED*direction;
					else
						speed = nextBlock.walkSpeed * Settings.PEA_SPEED * direction;
					
					goal.x -= Settings.modifiedPeaRadius *2* direction+6; 				
					currentBlock.x += direction;
					calculateNextGoal = calculateRampGoal;	
				}else if (moveStateStep == "beginOverhangNinjaJump")
				{
					//Begin ninja jump sequence
					beginWallNinjaJump(model);
					
				}
				moveStateStep = "";
			}else if (!model.hasBlock(currentBlock.x, currentBlock.y + 1) && 
						model.hasBlock(currentBlock.x + direction, currentBlock.y) )
			{
				
				nextBlock = model.getBlock(currentBlock.x+direction, currentBlock.y);
				if ((nextBlock.title == Settings.blocks.exit.title ||
				nextBlock.title == Settings.blocks.spikey.title 	||
					nextBlock.title == Settings.blocks.standard.title || 
					nextBlock.title == Settings.blocks.gel.title || 
					nextBlock.title == Settings.blocks.spring.title ||
					(nextBlock.title == Settings.blocks.leftRamp.title && direction == Settings.LEFT) ||
					(nextBlock.title == Settings.blocks.topLeftRamp.title && direction == Settings.LEFT) ||
					(nextBlock.title == Settings.blocks.rightRamp.title && direction == Settings.RIGHT)||
					(nextBlock.title == Settings.blocks.topRightRamp.title && direction == Settings.RIGHT))&& currentBlock.y +1 <= model.maxYBlocks)
				{
					//climbing	
					trace("climbing")
					goal = GameModel.convertBlockToGameCoord(currentBlock.x, currentBlock.y);				
					goal.y -= Settings.modifiedBlockHeight-Settings.modifiedPeaRadius;
					this.speed = model.getBlock(currentBlock.x + direction, currentBlock.y).climbSpeed * Settings.PEA_SPEED;
					currentBlock.y += 1;
				}else if (nextBlock.title == Settings.blocks.leftRamp.title && !model.hasBlock(currentBlock.x+direction, currentBlock.y + 1) && currentBlock.y +1 <= model.maxYBlocks)
				{
					trace("finish climb to slide 1")
					moveStateStep = "finishClimbToSlide";
					//start climbing left ramp slope
					goal = GameModel.convertBlockToGameCoord(currentBlock.x + direction, currentBlock.y);				
					goal.y += Settings.modifiedPeaRadius - 9;
					
				}else if (nextBlock.title == Settings.blocks.rightRamp.title && !model.hasBlock(currentBlock.x+direction, currentBlock.y + 1)&& currentBlock.y +1 <= model.maxYBlocks)
				{
					trace("finish climb to slide 2")
					moveStateStep = "finishClimbToSlide";
					//start climbing right ramp slope
					goal = GameModel.convertBlockToGameCoord(currentBlock.x + direction, currentBlock.y);				
					goal.y += Settings.modifiedPeaRadius - 9;
				}else
				{
					trace("begin ninja wall jump");
					beginWallNinjaJump(model);
				}
			}else if (!model.hasBlock(currentBlock.x, currentBlock.y + 1) && !model.hasBlock(currentBlock.x + direction, currentBlock.y + 1))
			{	
				//transition to walking
				goal = GameModel.convertBlockToGameCoord(currentBlock.x, currentBlock.y);
				goal.y += Settings.modifiedPeaRadius;
				moveStateStep = "finishClimbToWalk";
				
			}else if (model.hasBlock(currentBlock.x, currentBlock.y + 1) && model.hasBlock(currentBlock.x + direction, currentBlock.y) &&
				!(model.getBlock(currentBlock.x + direction, currentBlock.y).title == Settings.blocks.leftRamp.title &&  direction == Settings.RIGHT) && 
				!(model.getBlock(currentBlock.x + direction, currentBlock.y).title == Settings.blocks.rightRamp.title && direction == Settings.LEFT))
			{
				goal = GameModel.convertBlockToGameCoord(currentBlock.x, currentBlock.y + 1);
				goal.y += Settings.modifiedPeaRadius * 2;
				moveStateStep = "beginOverhangNinjaJump";
			}
			else
			{
				
				goal = GameModel.convertBlockToGameCoord(currentBlock.x, currentBlock.y);
				goal.y += Settings.modifiedPeaRadius;
				moveStateStep = "finishClimbToWalk";
			}
		}
		
		private function walking(dt:Number):Number
		{
			
			var dist:Number = goal.x - x;		
		
			var timeLeft:Number = dt - dist /(speed * dt)*dt;
			
			if (timeLeft > 0)
			{	
				
				this.x = goal.x;
				return timeLeft;
			}else
			{
				this.x += speed * dt;	
				return 0;
			}
		}
		
		private function climbing(dt:Number):Number
		{
			var dist:Number = goal.y - y;		
		
			var timeLeft:Number = dt - dist /(-Math.abs(speed) * dt)*dt;
			
			if (timeLeft > 0)
			{	
				this.y = goal.y;
				return timeLeft;
			}else
			{
				this.y -= Math.abs(speed) * dt;	
				return 0;
			}
		}
		
		private function calculateRampGoal(model:GameModel):void
		{
			this.moveState = sliding;
			this.directionY = 1;
			logger.log("sliding up")
			
			goal = GameModel.convertBlockToGameCoord(currentBlock.x+direction, currentBlock.y+1);				
			goal.x -= Settings.modifiedPeaRadius * direction * 2+4*direction;
			currentBlock.y ++;
			currentBlock.x += direction;
			calculateNextGoal = calculateWalkingGoal;
		}
		private function calculateRampDownGoal(model:GameModel):void
		{
			
			currentBlock = GameModel.convertGameToBlockCoord(this.x, this.y);
			
			logger.log("current block: " + currentBlock);
			logger.log("moveState: " + moveStateStep);
			this.moveState = sliding;
			if (moveStateStep == "")
			{
				this.directionY = -1;
				goal = GameModel.convertBlockToGameCoord(currentBlock.x + direction, currentBlock.y-1);				
				goal.x -= Settings.modifiedPeaRadius * direction * 3;
				goal.y -= Settings.modifiedBlockHeight / 8 * 3;
			
				//TODO Detect what the next block will be and choose the next goal
				
				moveStateStep = "calculateTransitionGoal";
			}else if (moveStateStep == "calculateTransitionGoal")
			{
				var nextBlock:Block = model.getBlock(currentBlock.x + direction , currentBlock.y);
				
				
				if (nextBlock == null)
				{
					var nextBlockDown:Block = model.getBlock(currentBlock.x + direction, currentBlock.y - 1)
					
					logger.log("_____>" + nextBlockDown);
					if (nextBlockDown  != null && ((nextBlockDown.title == Settings.blocks.leftRamp.title && direction == Settings.LEFT) ||
						(nextBlockDown.title == Settings.blocks.rightRamp.title && direction == Settings.RIGHT)))
					{
						this.directionY = -1;
						goal = GameModel.convertBlockToGameCoord(currentBlock.x + direction*2, currentBlock.y-1);					
						goal.x -= Settings.modifiedPeaRadius * direction * 3+direction*3;
						goal.y -= Settings.modifiedBlockHeight / 8 * 3;
						moveStateStep = "calculateTransitionGoal";
					}else if (false && (nextBlockDown == null && model.hasBlock(currentBlock.x + direction * 2, currentBlock.y - 1)))
					{
						beginGapJump(model);
					}else
					{
						moveStateStep = "slidingTransitionToWalking";					
					}
				}else if ((nextBlock.title == Settings.blocks.leftRamp.title && direction == Settings.RIGHT) ||
					(nextBlock.title == Settings.blocks.rightRamp.title && direction == Settings.LEFT)	)					
				{
					
					moveStateStep = "slidingTransitionToRamp";	
					logger.log(moveStateStep)
				}else
				{
					
					calculateNextGoal = calculateWalkingGoal;
					
				}
			}else if (moveStateStep == "slidingTransitionToWalking")
			{
				goal = GameModel.convertBlockToGameCoord(currentBlock.x + direction, currentBlock.y);								
				goal.x -= Settings.modifiedPeaRadius * direction+direction*13;
				moveStateStep = "";
				calculateNextGoal = calculateWalkingGoal;
			}else if (moveStateStep == "slidingTransitionToRamp")
			{
				goal = GameModel.convertBlockToGameCoord(currentBlock.x + direction, currentBlock.y);								
				goal.x -= Settings.modifiedPeaRadius * direction+direction*13;
				goal.y -= 5;
				
				moveStateStep = "finishTransitionToRamp";
				
			}else if (moveStateStep == "finishTransitionToRamp")
			{
				moveStateStep = "";
				
				calculateNextGoal = calculateRampGoal;	
			}
			
			
		
			//clickedContinue = false;
			
		}
		
		private function calculateLevelCompleted(model:GameModel):void
		{
			stage.dispatchEvent(new DataEvent(PlayWithYourPeas.LEVEL_COMPLETED_EVENT, {pea:this  } ));
		}
		private var lastTimeLeft:Number = -5000;
		private function sliding(dt:Number):Number
		{
			
			var dx:Number = goal.x - x;
			var dy:Number = goal.y - y;
			
			var dist:Number = Math.sqrt(Math.pow(goal.x - x, 2)+ Math.pow(goal.y - y, 2));		
			
			
			var timeLeft:Number = dt - dist / (speed * dt * direction) * dt;
			
			
			
			if (timeLeft > 0 || lastTimeLeft > timeLeft)
			{	
				this.x = goal.x;
				this.y = goal.y;
				lastTimeLeft = -5000;
				return timeLeft;
			}else
			{
				var moveDist:Number = speed * dt;
				
				var angle:Number = Math.atan( -dy / dx);
				
				this.y += Math.sin(angle) * moveDist*(dy/Math.abs(dy))*directionY;				
				this.x += Math.cos(angle) * moveDist * (dx / Math.abs(dx)) * direction;
				lastTimeLeft = timeLeft;
				return 0;
			}
		}
		
		/**
		 * Adds the block if it has not already been added, returns the total number of times the current block has been hit
		 * @param	block
		 * @return
		 */
		public function addBounceBlock(block:Block):Number
		{
			var blockIndex:Number = findBounceBlock(block) ;
			var totalHits:Number = 1;
			if (blockIndex == -1)			
			{
				currentBounceBlocks.push( { block:block, hits:1 } );
				
				if (scoredJump)
					stage.dispatchEvent(new DataEvent(PlayWithYourPeas.UPDATE_MULTIPLIER_EVENT, { pea:this, multiplier:currentBounceBlocks.length } ));
			}
			else
			{
				currentBounceBlocks[blockIndex].hits++;
				totalHits = currentBounceBlocks[blockIndex].hits;
			}
			
			return totalHits;
		}
		/**
		 * Looks through the list of bounce blocks and returns the index of the block otherwise it returns -1
		 * @param	block
		 * @return
		 */
		private function findBounceBlock(block:Block):Number
		{
			var bFound:Boolean = false;
			var index:Number = 0;
			while (!bFound && index < currentBounceBlocks.length )
			{
				if (currentBounceBlocks[index].block == block)
				{
					bFound = true;
				}else
				{
					index++;
				}
			}
			if (bFound)
				return index;
			else
				return -1;
		}
		public function scoreJump():Number
		{
			if (!scoredJump ) return 0; 
			
			var score:Number = currentBounceBlocks.length;
			score *= Settings.HAPPY_POINTS_PER_BLOCK;
			
			stage.dispatchEvent(new DataEvent(PlayWithYourPeas.SCORE_EVENT, { score: score, pea:this } ));
			return score;
		}
		
		public function get usingPhysics():Boolean { return _usingPhysics; }
		
		public function set usingPhysics(value:Boolean):void 
		{
			_usingPhysics = value;
		}
		
		public function get worldBody():b2Body { return _worldBody; }
		
		public function set worldBody(value:b2Body):void 
		{
			_worldBody = value;
		}
		
		public function get currentBlock():Point { return _currentBlock; }
		
		public function set currentBlock(value:Point):void 
		{
			_currentBlock = value;
		}
		
		public function get peaSleepCounter():Number { return _peaSleepCounter; }
		
		public function set peaSleepCounter(value:Number):void 
		{
			_peaSleepCounter = value;
		}
		
		public function get alive():Boolean { return _alive; }
		
		public function set alive(value:Boolean):void 
		{
			_alive = value;
		}
		
		public function get currentBounceBlocks():Array { return _currentBounceBlocks; }
		
		public function set currentBounceBlocks(value:Array):void 
		{
			_currentBounceBlocks = value;
		}
		
		public function get gapJump():Boolean { return _gapJump; }
		
		public function set gapJump(value:Boolean):void 
		{
			_gapJump = value;
		}
		
		public function get switchedDirectionsDuringJump():Boolean { return _switchedDirectionsDuringJump; }
		
		public function set switchedDirectionsDuringJump(value:Boolean):void 
		{
			_switchedDirectionsDuringJump = value;
		}
		
		public function get personalScore():Number { return _personalScore; }
		
		public function set personalScore(value:Number):void 
		{
			_personalScore = value;
		}
		
		public function get scoredJump():Boolean { return _scoredJump; }
		
		public function set scoredJump(value:Boolean):void 
		{
			_scoredJump = value;
		}
		public function getDirection():Number
		{
			return direction;
		}
		
		public function updateCurrentBlock():void
		{
			currentBlock = GameModel.convertGameToBlockCoord(this.x, this.y);
		}
		
	}
	
}
