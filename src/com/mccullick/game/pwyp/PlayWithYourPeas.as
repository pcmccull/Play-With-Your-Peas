package com.mccullick.game.pwyp 
{
	import Box2D.Dynamics.b2Body;
	import caurina.transitions.Tweener;
	import com.mccullick.events.DataEvent;
	import com.mccullick.game.DetectSite;
	import com.mccullick.pwyp.assets.IntroAnim;
	import com.mccullick.utils.SpriteManager;
	import com.reintroducing.sound.SoundManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event; 
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	import mochi.as3.MochiDigits;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class PlayWithYourPeas 
	{
		private var gui:GameUI;
		private var view:GameView;
		private var model:GameModel;
		public static var stage:Stage = null;
		private var root:Sprite;
		private var entranceBlock:Block;
		
		public static const SCORE_EVENT:String = "SCORE_EVENT";
		public static const UPDATE_MULTIPLIER_EVENT:String = "UPDATE_MULTIPLIER_EVENT";
		public static const PEA_KILLED_EVENT:String = "PEA_KILLED_EVENT";
		public static const LEVEL_COMPLETED_EVENT:String = "LEVEL_COMPLETE";
		public static const END_SPECIAL_ITEM:String = "END_SPECIAL_ITEM";
		
		public static const MODE_RUNNING:String = "running";
		public static const MODE_BUILDING:String = "building";
		public var mode:String;
		
		public static const LOAD_CUSTOM:String = "LOAD_CUSTOM";
		
		private var pea:Pea;
		private var scoreEventInProgress:Array = new Array();
		
		public static const PAUSE_GAME:String = "PAUSE_GAME";
		
		private var lastUpdateTime:Number;
		private var bMusicPlaying:Boolean = false;
		public function PlayWithYourPeas(stage:Stage, root:Sprite) 
		{
			PlayWithYourPeas.stage = stage;
			this.root = root;
			
			//try to load previous played game
			GameStats.getInstance().load();
			
			//initialize the game
			initDisplay();	
			
			//show the main menu
			showMainMenu();
	
		}
		
		private function initDisplay():void
		{
			//add the background image
			var background:Sprite = SpriteManager.getSprite( "Background") as Sprite;
			background.x -= 1;
			background.y -= 1;
			
			root.addChild(background);
			
			model = new GameModel();
			
			//add a new game view
			view = new GameView();
			view.y = Settings.GAME_VIEW_OFFSET_Y;
			view.x = Settings.GAME_VIEW_OFFSET_X;
			root.addChild(view);
			
			var debugDraw:Sprite = new Sprite();
			debugDraw.y = Settings.GAME_VIEW_OFFSET_Y;
			debugDraw.x = Settings.GAME_VIEW_OFFSET_X;
			model.setupDebugDraw(debugDraw);
			debugDraw.alpha = .5;
			root.addChild(debugDraw);
			
			//add the gui
			gui = new GameUI();
			gui.addEventListener(GameUI.ON_RESET_LEVEL, function(evt:Event):void
				{
					resetLevel();
				})
			gui.addEventListener(GameUI.CONTINUE_GAME, onContinueGame);
			gui.addEventListener(GameUI.PAUSE_GAME, pauseGame);
			gui.addEventListener(GameUI.UNPAUSE_GAME, function(evt:Event):void { unpauseGame () } );
			gui.addEventListener(GameUI.RUN_TEST, runTest);
			gui.addEventListener(GameUI.END_TEST, endTest);
			root.addChild(gui);
			
			
			
			stage.addEventListener(END_SPECIAL_ITEM, onEndSpecialItem);
		}
		
		private function onContinueGame(evt:Event):void
		{
			
			if (GameStats.getInstance().gameInProgress &&
				GameStats.getInstance().levelTime != null && GameStats.getInstance().levelTime.value > 0)
			{
				unpauseGame();
			}else
			{
				if (model != null)
				{
					model.cleanup();
					view.cleanup();
				}
				gui.showToolbar();			
				gui.showScoreboard();
				startLevel();
			}
		}
		
		private function showMainMenu():void
		{
			gui.showMainMenu();
			
			gui.addEventListener(GameUI.START_GAME, function(evt:Event):void
					{
						if (model != null)
						{
							model.cleanup();
							view.cleanup();
						}
						gui.hideMainMenu();
						gui.showToolbar();			
						gui.showScoreboard();
						
						startLevel();
						
						//SoundManager.getInstance().playSound("fxItsAPeasGame", .4*Settings.SOUND_VOLUME, 0, .6, "fx");
					});
			gui.addEventListener(GameUI.OPEN_EDITOR, function(evt:Event):void
					{
						gui.hideMainMenu();
						gui.showEditor();
					
					});
		}
		
		public function loadCustomLevel(params:Object):void
		{
			
		}

		private function startLevel(fastStart:Boolean = false):void
		{
			
			if (!bMusicPlaying)
			{
				/*SoundManager.getInstance().playSound("funkyMusic", .7 * Settings.SOUND_VOLUME, 0, 999, "music");*/
				bMusicPlaying = true;
			}
			mode = MODE_BUILDING;
			

			GameStats.getInstance().gameInProgress = true;
			TextField(gui.getScoreboard().getChildByName("goal")).text = GameStats.getInstance().currentLevel.targetScore.value + "";
			TextField(gui.getScoreboard().getChildByName("goalInstruction")).text = "Goal";
			paused = false;
			
			//load the level			
			scoreEventInProgress = new Array()			
			//show the toolbar		
			var stats:GameStats = GameStats.getInstance()
			
			
			gui.selectTool("standard");			
			
			Settings.modifiedBlockHeight = Settings.BLOCK_HEIGHT * stats.currentLevel.scale;
			Settings.modifiedBlockWidth = Settings.BLOCK_WIDTH * stats.currentLevel.scale;
			Settings.modifiedPeaRadius = Settings.PEA_RADIUS * stats.currentLevel.scale;
			
			Settings.modifiedGameViewOffsetY = Settings.GAME_VIEW_OFFSET_Y + 3 * 1 / GameStats.getInstance().currentLevel.scale;
			stats.levelTime = new MochiDigits(0);
			stats.happyPoints = new MochiDigits(0);
			
			lastUpdateTime = getTimer();
			
			model.init();			
			view.init();
			
			//add the pea			
			pea = new Pea(stats.currentLevel.entrancePoint.x, stats.currentLevel.entrancePoint.y);
			model.addPea(pea );
			view.addPea(pea );	
			pea.alpha = 0;
			
			
			
			//show/hide tools
			gui.hideAllTools();
			gui.showTools(stats.currentLevel.tools);
			
			
			
			entranceBlock = Settings.blocks.entranceBlock.cloneWithLocation(stats.currentLevel.entrancePoint.x, stats.currentLevel.entrancePoint.y);
			
			addBlock(entranceBlock, new Point(entranceBlock.blockX, entranceBlock.blockY)); 
		
			
			
			var exit:Block = Settings.blocks.exit.clone();
			addBlock(exit, stats.currentLevel.exitPoint);
			
			exit._fixedBlock = true;
			var matrix:Array = new Array();
			matrix=matrix.concat([0.6,0.5,0.5,0,0]);// red
			matrix=matrix.concat([0.5,0.55,0.5,0,0]);// green
			matrix=matrix.concat([0.5,0.5,0.7,0,0]);// blue
			matrix=matrix.concat([0,0,0,1,0]);// alpha
			var bwFilter:ColorMatrixFilter=new ColorMatrixFilter(matrix);			
			Sprite(Sprite(exit.sprite).getChildByName("block")).filters = [bwFilter];
			
			for each(var blockObj:Object in stats.currentLevel.startingBlocks)
			{
				var nextBlock:Block = Settings.blocks[blockObj.block].cloneWithLocation(blockObj.x, blockObj.y);
				addBlock(nextBlock, new Point(nextBlock.blockX, nextBlock.blockY));
				nextBlock.fixedBlock = true;
				nextBlock.completelyFixed = true;
				trace(nextBlock.x  + " " + nextBlock.y);
				if (Sprite(nextBlock.sprite).getChildByName("block") == null)
				{
					var blockSprite:Sprite = SpriteManager.getSprite(nextBlock.blockId) as Sprite;
					blockSprite.name = "block";
					Sprite(nextBlock.sprite).addChild(blockSprite );
					
				}
				Sprite(Sprite(nextBlock.sprite).getChildByName("block")).filters = [bwFilter];
			}
			
			for each(var nextSpecialItem:Object in stats.currentLevel.specialItems)
			{
				var item:SpecialItem = SpecialItemFactory.getInstance().createItem(nextSpecialItem.type);
				view.addSpecialItem(item, nextSpecialItem.x, nextSpecialItem.y);
				model.addSpecialItem(item);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			gui.addEventListener(GameUI.ON_PLACE_TOOL, onPlaceTool);
			stage.addEventListener(SCORE_EVENT, onScoreEvent);
			stage.addEventListener(PEA_KILLED_EVENT, onPeaKilledEvent);
				
			stage.addEventListener(PlayWithYourPeas.LEVEL_COMPLETED_EVENT, onLevelComplete);
			
			if (entranceBlock.sprite == null)
			{
				
				entranceBlock.sprite = SpriteManager.getSprite(entranceBlock.blockId) as Sprite;
				
				
			}
			var glow:Sprite = Sprite(entranceBlock.sprite).getChildByName("glow") as Sprite;
			glow.alpha = 0;
			
			
			//start animations
			stage.addEventListener(Event.ENTER_FRAME, update);
			
			gui.addEventListener(PlayWithYourPeas.PAUSE_GAME, pauseGame);
			if (!fastStart)
			{
				//show tutorial screens
				if (stats.currentLevel.tutorials != null)
				{
					gui.startTutorial();
					gui.tutorial.showStartupInstructions();
					var clickCount:Number = 1;
					gui.tutorial.instructions.gotoAndStop(stats.currentLevel.tutorials[clickCount-1]);
					var onTutorialClicked:Function = function(evt:MouseEvent):void
					{					
						clickCount++;
						if (clickCount > stats.currentLevel.tutorials.length)
						{
							stage.removeEventListener(MouseEvent.MOUSE_DOWN, onTutorialClicked);
							unpauseGame();
							showIntroAnim();
							gui.tutorial.hide()
						}else
						{
							 gui.tutorial.instructions.gotoAndStop(stats.currentLevel.tutorials[clickCount-1]);
						}
					}
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onTutorialClicked);
					pauseGame(new Event(PAUSE_GAME));
					update(new Event(Event.ENTER_FRAME));
				}else
				{
					showIntroAnim();
				}
			}
			gui.showStartButton();
		
		}
		
		private function runTest(evt:Event):void
		{
			gui.hideStartButton();
			
			var glow:Sprite = Sprite(entranceBlock.sprite).getChildByName("glow") as Sprite;
			glow.alpha = 0;
			pea.visible = true;
			pea.alpha = 0;
		
			Tweener.addTween(pea , { alpha:1, transition:"linear", time:1, delay:1.5 } );
			Tweener.addTween(glow, { alpha:1, transition:"bounce", time:2, onComplete:function():void
					{
						pea.startPhysics(model);
						Tweener.addTween(glow, { alpha:0, transition:"bounce", time:.4, delay:.4, onComplete:function():void
						{
							if (pea.alive)
								gui.showStopButton();
						}} );
						mode = MODE_RUNNING;
					}});
		}
		
		private function endTest(evt:Event):void
		{
			gui.showStartButton();
			gui.hideStopButton();
			mode = MODE_BUILDING;
			pea.alpha = 0;
			
			var stats:GameStats = GameStats.getInstance()
			pea.x = stats.currentLevel.entrancePoint.x;
			pea.y = stats.currentLevel.entrancePoint.y;
			onPeaKilledEvent(new DataEvent(PEA_KILLED_EVENT, { resetDelay:0 } ));
			
		}
		
		private function showIntroAnim():void
		{
			pauseGame(new Event(MouseEvent.CLICK));
			view.alpha = 0;
			gui.alpha = 0;
			var intro:IntroAnim = new IntroAnim();
			intro.x = Settings.GAME_WIDTH / 2;
			intro.y = Settings.GAME_HEIGHT * 2;
			intro.levelNumber.text = "level " + (GameStats.getInstance().currentLevelIndex + 1);
			intro.levelTitle.text = GameStats.getInstance().currentLevel.title;
			intro.goal.text = GameStats.getInstance().currentLevel.targetScore.value + "";
			root.addChild(intro);
			
			intro.alpha = 0;
			Tweener.addTween(intro, { alpha:1, y:Settings.GAME_HEIGHT / 2, time:.5, transition:"bounce", onComplete:function():void
			{
				
				Tweener.addTween(intro, { alpha:0, y:0, scaleX:0, scaleY:0, delay:1.5, time:.5, onComplete:function():void
				{
					unpauseGame();
					Tweener.addTween(view, { alpha:1, time:1 } );
					Tweener.addTween(gui, { alpha:1, time:1 } );
					root.removeChild(intro)
				}});
			}});
		}
		private function onPeaKilledEvent(evt:DataEvent):void
		{
		
			gui.hideStopButton();
			mode = MODE_BUILDING;
			var resetDelay:Number = 2000;
			
			if (evt.data.resetDelay != null)
				resetDelay = evt.data.resetDelay;
				
			var resetTimer:Timer  = new Timer(resetDelay, 0)
			
			var onCreatePeaDelay:Function = function(evt:Event):void
				{
					var createNewPea:Function = function(evt:Event):void
					{
							gui.showStartButton();
						stage.removeEventListener(Event.ENTER_FRAME, createNewPea);
						
						var stats:GameStats = GameStats.getInstance()
						
						pea = new Pea(stats.currentLevel.entrancePoint.x, stats.currentLevel.entrancePoint.y);
						model.addPea(pea);
						view.addPea(pea);
						pea.alpha = 0;
						var glow:Sprite = Sprite(entranceBlock.sprite).getChildByName("glow") as Sprite;
						glow.alpha = 0;
						
						model.resetBlocks();
						TextField(gui.getScoreboard().getChildByName("goal")).text = GameStats.getInstance().currentLevel.targetScore.value + "";
						TextField(gui.getScoreboard().getChildByName("goalInstruction")).text = "Goal"
						
						GameStats.getInstance().happyPoints.value = 0;
						gui.updateScoreboard();
					}
					stage.addEventListener(Event.ENTER_FRAME, createNewPea);
					
					resetTimer.removeEventListener(TimerEvent.TIMER, onCreatePeaDelay);
					resetTimer.stop();
					resetTimer = null;
					gui.updateScoreboard();
				}
			
			resetTimer.addEventListener(TimerEvent.TIMER,onCreatePeaDelay );
			resetTimer.start();
			
			resetSpecialItems()
		}
		
		private function resetSpecialItems():void
		{
			model.removeAllSpecialItems();
			view.removeAllSpecialItems();
			for each(var nextSpecialItem:Object in GameStats.getInstance().currentLevel.specialItems)
			{
				var item:SpecialItem = SpecialItemFactory.getInstance().createItem(nextSpecialItem.type);
				view.addSpecialItem(item, nextSpecialItem.x, nextSpecialItem.y);
				model.addSpecialItem(item);
			}
		}
	
		private function onEndSpecialItem(evt:DataEvent):void
		{
			if (evt.data.score != undefined)
			{
				onScoreEvent(evt);
			}
			
			model.removeSpecialItem(evt.data.item);
			view.removeSpecialItem(evt.data.item);
		}
		
		private function onScoreEvent(evt:DataEvent):void
		{
			
			var newScore:Number = evt.data.score;
			if (newScore > 0)
			{
				scoreEventInProgress.push(true);
				view.showPeaScored(newScore);
				
				
				var timer:Timer = new Timer(1500, 1);
				
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(evt:Event):void
				{
					GameStats.getInstance().happyPoints.addValue(newScore);
					
					scoreEventInProgress.pop();
				});
				timer.start();
				
				var totalScore:Number = GameStats.getInstance().happyPoints.value + newScore;
				if (totalScore >= GameStats.getInstance().currentLevel.targetScore.value)
				{
					pea.mc.bandana.visible = true;
					var band:MovieClip = pea.mc.bandana.getChildByName("bandColor") as MovieClip;
					var oldBandLevel:Number = pea.bandanaLevel;
					var newColorTransform:ColorTransform = band.transform.colorTransform;
					if (totalScore >= GameStats.getInstance().currentLevel.gold.value)
					{
						newColorTransform.color = 0x3A3B32;
						pea.bandanaLevel = 3;
						TextField(gui.getScoreboard().getChildByName("goal")).text = "";
						TextField(gui.getScoreboard().getChildByName("goalInstruction")).text = "";
					}else if (totalScore >= GameStats.getInstance().currentLevel.silver.value)
					{
						newColorTransform.color = 0x0732CE;
						pea.bandanaLevel = 2;
						TextField(gui.getScoreboard().getChildByName("goal")).text = GameStats.getInstance().currentLevel.gold.value + "";
						TextField(gui.getScoreboard().getChildByName("goalInstruction")).text = "Black belt"
					}else
					{
						newColorTransform.color = 0xF9FED7;
						pea.bandanaLevel = 1;
						TextField(gui.getScoreboard().getChildByName("goal")).text = GameStats.getInstance().currentLevel.silver.value + "";
						TextField(gui.getScoreboard().getChildByName("goalInstruction")).text = "Blue belt"
					}
					
					band.transform.colorTransform = newColorTransform;		
					if (oldBandLevel < pea.bandanaLevel)
						view.showConfetti(newColorTransform.color, pea.x, pea.y);
				}
				
				/*var pea:Pea = evt.data.pea;
				pea.personalScore += newScore;
				
				if (pea.personalScore >= Settings.PEA_SPLIT_SCORE)
				{
					pea.personalScore = 0;
					var newPea:Pea = new Pea(pea.x, pea.y);
					model.addPea(newPea);
					view.addPea(newPea);
					if (newPea.getDirection() == pea.getDirection())
					{
						newPea.switchDirections();
						newPea.updateCurrentBlock();
					}
				}
				*/
			}
			
		}
		private function onMouseMove(evt:MouseEvent):void
		{	
			if (mode == MODE_RUNNING) 
			{
				view.hideOverBlock();
				return;
			}
			var gamePoint:Point = GameModel.convertStageToGameCoord(evt.stageX, evt.stageY);				
			var blockPoint:Point = GameModel.convertGameToBlockCoord(gamePoint.x, gamePoint.y+(Settings.BLOCK_HEIGHT*GameStats.getInstance().currentLevel.scale)/4);
			var tool:String = gui.getSelectedTool();
			if (tool != "deleteTool" && model.isValidBlockPoint(blockPoint.x, blockPoint.y) && !GameStats.getInstance().currentLevel.entrancePoint.equals(blockPoint) && !paused  )
			{
				var addedBlock:Block = Settings.blocks[tool].clone();						
				view.showOverBlock(addedBlock, blockPoint.x, blockPoint.y);
				
			}else
			{
				view.hideOverBlock();
			}
		}
		private function onPlaceTool(evt:PWYPEvent):void
		{
			if (mode == MODE_RUNNING) return;
			//check if there is an opening at this location
			var gamePoint:Point = GameModel.convertStageToGameCoord(evt.data.x, evt.data.y);				
			var blockPoint:Point = GameModel.convertGameToBlockCoord(gamePoint.x, gamePoint.y+(Settings.BLOCK_HEIGHT*GameStats.getInstance().currentLevel.scale)/4);
			var tool:String = evt.data.tool;
			var block:Block = model.getBlock(blockPoint.x, blockPoint.y);
			
			if (tool == "deleteTool"&&  block !=null && !block.fixedBlock)
			{
				//model remove block
				var removedBlock:Block = model.removeBlock(blockPoint.x, blockPoint.y);
				
				//view remove block
				view.removeBlock(removedBlock);
			}else if (!model.hasBlock(blockPoint.x, blockPoint.y) && tool != "deleteTool"&& !GameStats.getInstance().currentLevel.entrancePoint.equals(blockPoint) )
			{
				
				var addedBlock:Block = Settings.blocks[tool].clone();						
				addBlock(addedBlock, blockPoint);
			}
		}
		
		private var levelCompleteData:Object;
		private function onLevelComplete(evt:Event):void
		{	
			gui.hideStopButton();
			if (evt is DataEvent)
			{
				levelCompleteData = DataEvent(evt).data
			}
			
			if (scoreEventInProgress.length > 0)
			{
				stage.addEventListener(Event.ENTER_FRAME, onLevelComplete);
			}else
			{
				stage.removeEventListener(Event.ENTER_FRAME, onLevelComplete);
				trace("final score: " + GameStats.getInstance().happyPoints.value);
				if (GameStats.getInstance().happyPoints.value >= GameStats.getInstance().currentLevel.targetScore.value)
				{
					//show success animation and score
					stage.removeEventListener(Event.ENTER_FRAME, update);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					stage.removeEventListener(LEVEL_COMPLETED_EVENT, onLevelComplete);
					gui.removeEventListener(GameUI.ON_PLACE_TOOL, onPlaceTool);
					stage.removeEventListener(SCORE_EVENT, onScoreEvent);
					stage.removeEventListener(PEA_KILLED_EVENT, onPeaKilledEvent);
					
					//start the next level
					trace("Finishing level");
					stage.addEventListener(Event.ENTER_FRAME, endLevel);
				}else
				{
					SoundManager.getInstance().playSound("fxUhOh", 1 * Settings.SOUND_VOLUME, 0, 0, "fx");
					levelCompleteData.pea.say("AlertFail");
					var goalArrow:Sprite = gui.getScoreboard().getChildByName("goalArrow") as Sprite;
					goalArrow.x = -goalArrow.width;
					Tweener.addTween(goalArrow, { x:171, alpha:1, time:1, transition:"easeOutSine", onComplete:function():void
						{
							Tweener.addTween(goalArrow, { alpha:0, delay:2, time:1, transition:"easeOutSine" } );
						}});
					model.killPea(levelCompleteData.pea, false);
					
				}
			}
				
		}
		
		private function addBlock(block:Block, blockPoint:Point):void
		{
			
			//model add block
			var success:Boolean = model.addBlock(block, blockPoint.x, blockPoint.y );
			
			if (success)
			{
				//view add block						
				view.addBlock(block, blockPoint.x, blockPoint.y);
				model.setTopBlock(block, blockPoint.x, blockPoint.y);
			}
		}
		public var paused:Boolean = true;
		public function pauseGame(evt:Event):void
		{
			paused = true;
			stage.removeEventListener(Event.ENTER_FRAME, update);
			gui.removeEventListener(GameUI.ON_PLACE_TOOL, onPlaceTool);
		}
		
		public function unpauseGame():void
		{
			paused = false;
			lastUpdateTime = getTimer();
			stage.addEventListener(Event.ENTER_FRAME, update);
			
			gui.addEventListener(GameUI.ON_PLACE_TOOL, onPlaceTool);
		}
		
		
		
		private function update(evt:Event):void
		{
			var dt:int = getTimer() - lastUpdateTime;
			dt *= GameStats.getInstance().currentGameSpeed.value;
			GameStats.getInstance().levelTime.addValue(dt);
			
			gui.updateScoreboard();
			var roundDT:Number = dt >> 2;
			
			if (mode == MODE_RUNNING)
			{
				model.update(roundDT);
				view.update(roundDT);
			}
			
			
			
			lastUpdateTime = getTimer();
		}
		private var bShownFunRating:Boolean = false;
		private function endLevel(evt:Event):void
		{
			
			GameStats.getInstance().gameInProgress = false;
			stage.removeEventListener(Event.ENTER_FRAME, endLevel);
			var stats:GameStats = GameStats.getInstance()	
			stats.totalHappyPoints.addValue(stats.happyPoints.value);
			gui.updateScoreboard();
			
			/*
			if (pea.bandanaLevel == 3 && Settings.levelScoreboards[GameStats.getInstance().currentLevelIndex] != undefined)
			{
				Mouse.show();
				//SHOW THE HIGH SCORE SCOREBOARD FOR THIS LEVEL
				
			}
			*/
			
			
			var onBeginNextLevel:Function = function(evt:Event):void
				{
					evt.stopPropagation();
					gui.hideEndOfLevelMenu();
					model.cleanup();
					view.cleanup();
					
					//next level
					if (GameStats.getInstance().currentLevelIndex < (Settings.levels.length-1))
						GameStats.getInstance().currentLevelIndex = GameStats.getInstance().currentLevelIndex + 1;
						
					startLevel();
				}
			var onTryAgain:Function = function(evt:Event):void
				{
					evt.stopPropagation();
					stage.removeEventListener(Event.ENTER_FRAME, endLevel);
					gui.hideEndOfLevelMenu();
					stage.addEventListener(Event.ENTER_FRAME, update);
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					stage.addEventListener(LEVEL_COMPLETED_EVENT, onLevelComplete);
					gui.addEventListener(GameUI.ON_PLACE_TOOL, onPlaceTool);
					stage.addEventListener(SCORE_EVENT, onScoreEvent);
					stage.addEventListener(PEA_KILLED_EVENT, onPeaKilledEvent);
					endTest(new  Event("ended"));
				}
			var onBeginSelectedLevel:Function = function():void
				{
					evt.stopPropagation();
					gui.hideEndOfLevelMenu();
					model.cleanup();
					view.cleanup();
				
					startLevel();
				}
			gui.showEndOfLevelMenu(onBeginNextLevel, onTryAgain, onBeginSelectedLevel);
			
			saveGame();
			
			if (!bShownFunRating && Math.random() < .1 && GameStats.getInstance().currentLevelIndex > 0)
			{
				gui.showFunRating()
				bShownFunRating = true;
			}
		}
		
		private function saveGame():void
		{
			GameStats.getInstance().save();
			
		}
		private function resetLevel():void
		{
			pauseGame(new Event("pause"));
			model.cleanup();
			view.cleanup();
			gui.showStartButton();
			gui.hideStopButton();
			startLevel(true);
		}
		
		
	}
	
	
}