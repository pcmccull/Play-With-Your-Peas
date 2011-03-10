package com.mccullick.game.pwyp 
{
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import caurina.transitions.Tweener;
	import com.mccullick.events.DataEvent;
	import com.mccullick.game.pwyp.editor.PWYPEditor;
	import com.mccullick.pwyp.assets.CommentDialog;
	import com.mccullick.pwyp.assets.EndOfLevelMenu;
	import com.mccullick.pwyp.assets.FunRating;
	import com.mccullick.pwyp.assets.LevelBox;
	import com.mccullick.pwyp.assets.PeaStandard;
	import com.mccullick.pwyp.assets.ResetMenu;
	import com.mccullick.pwyp.assets.StartButton;
	import com.mccullick.pwyp.assets.StopButton;
	import com.mccullick.utils.SpriteManager;
	import com.reintroducing.sound.SoundManager;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import mochi.as3.MochiDigits;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class GameUI extends Sprite
	{
		private var menus:Sprite;
		private var toolbars:Sprite;
		private var TOOLBAR_WIDTH:Number = 60;
		private var _toolbar:Sprite;
		private var pointers:Sprite;
		private var selectedTool:String;
		public var tutorial:Tutorial;
		private var startButton:StartButton;
		private var stopButton:StopButton;
		
		public static var START_GAME:String = "start_game";
		public static var OPEN_EDITOR:String = "open_editor";
		public static var ON_PLACE_TOOL:String = "ON_PLACE_TOOL";
		public static var ON_RESET_LEVEL:String = "ON_RESET_LEVEL";
		public static var PAUSE_GAME:String = "pause";
		public static var UNPAUSE_GAME:String = "unpause";
		public static var CONTINUE_GAME:String = "continue_game"
		public static var RUN_TEST:String = "run_test"
		public static var END_TEST:String = "end_test"
		
		public function GameUI() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.toolbars = new Sprite();
			this.addChild(toolbars);
			this.menus = new Sprite();
			this.addChild(menus);
			
			this.pointers = new Sprite();
			this.addChild(pointers);			
			initPointer();
		}
		
		private function initPointer():void
		{
			pointers.visible = false;
			pointers.x = mouseX;
			pointers.y = mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(evt:Event):void
			{
				pointers.visible = true;
				pointers.x = mouseX;
				pointers.y = mouseY;
			});
			stage.addEventListener(Event.MOUSE_LEAVE, function(evt:Event):void
				{
					pointers.visible = false;
				});
			Mouse.hide();
			pointers.mouseEnabled = false;
			pointers.mouseChildren = false;
			showStandardPointer();
		}
		
		public function showDeletePointer():void
		{
			if (pointers.getChildByName("delete") != null) return;
			
			if (pointers.getChildByName("standard") != null)
			{
				pointers.removeChild(pointers.getChildByName("standard"));
			}
			var pointer:DisplayObject = SpriteManager.getSprite("PointerDelete");
			pointer.name = "delete";
			pointers.addChild(pointer);			
		}
		
		public function showStandardPointer():void
		{
			if (pointers.getChildByName("standard") != null) return;
			
			if (pointers.getChildByName("delete") != null)
			{
				pointers.removeChild(pointers.getChildByName("delete"));
			}
			var pointer:DisplayObject = SpriteManager.getSprite("PointerStandard");
			pointer.name = "standard";
			pointers.addChild(pointer);
		}
		
		public function showMainMenu():void
		{
			var menu:Sprite = SpriteManager.getSprite("MainMenu") as Sprite;
			menu.name = "mainMenu";
			var logo:DisplayObject = menu.getChildByName("largeLogo");
			
			logo.scaleX = .1;
			logo.scaleY = .1;
			logo.alpha = .1;
			
			Tweener.addTween(logo, {  scaleX:1, scaleY:1, alpha:1, transition:"linear", time:.4, delay:.2, onComplete:function():void
						{
							logo.filters = [new GlowFilter(0xF9FED7, .8, 9, 9, 2, 1, false, false)];
						}
			} ); 
			Sprite(menu.getChildByName("pea")).getChildByName("bandana").visible = false;
			Sprite(menu.getChildByName("pea")).getChildByName("blinkLeft").visible = false;
			Sprite(menu.getChildByName("pea")).getChildByName("blinkRight").visible = false;
			menus.addChild(menu);
			
			var newGameBtn:SimpleButton = SimpleButton(menu.getChildByName("newGame_btn"));			
			newGameBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
				{
					evt.stopPropagation();
					GameStats.getInstance().currentLevelIndex = Settings.STARTING_LEVEL;
					
					dispatchEvent(new Event(GameUI.START_GAME));
				});
				
			var continueGameBtn:SimpleButton = SimpleButton(menu.getChildByName("continueBtn"));			
			continueGameBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
				{
					evt.stopPropagation();
					hideMainMenu();
					dispatchEvent(new Event(GameUI.CONTINUE_GAME));
				});
			if (GameStats.getInstance().gameInProgress)
			{
				enableButton(continueGameBtn);
			}else
			{
				disableButton(continueGameBtn);
			}
				
			var viewUserLevelsBtn:SimpleButton = SimpleButton(menu.getChildByName("viewUserLevelsBtn"));			
			viewUserLevelsBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
				{
					evt.stopPropagation();
					
					stage.dispatchEvent(new Event(PlayWithYourPeas.LOAD_CUSTOM));
				});
			viewUserLevelsBtn.visible = false;
			disableButton(viewUserLevelsBtn);
				
			var levelEditorBtn:SimpleButton = SimpleButton(menu.getChildByName("levelEditorBtn"));						
			levelEditorBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
				{
					evt.stopPropagation();
					dispatchEvent(new Event(GameUI.OPEN_EDITOR));
				});
			levelEditorBtn.visible = false;
			disableButton(levelEditorBtn);
				
			var creditsBtn:SimpleButton = SimpleButton(menu.getChildByName("creditsBtn"));			
			creditsBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
				{
					evt.stopPropagation();
					showCredits();
				});
			
		}		
		
		public function showStartButton():void
		{
			startButton.visible = true;
		}
		public function hideStartButton():void
		{
			startButton.visible = false;
		}
		public function showStopButton():void
		{
			stopButton.visible = true;
		}
		public function hideStopButton():void
		{
			stopButton.visible = false;
		}
		
		public function hideMainMenu():void
		{			
			if (menus.getChildByName("mainMenu") != null)
			{
				menus.removeChild(menus.getChildByName("mainMenu"));
			}
		}
		
		
		
	
		
		public function startTutorial():void
		{
			tutorial = new Tutorial();
			menus.addChild(tutorial);
		}
		public function showToolbar():void 
		{
			if (toolbar == null)
			{
				toolbar = SpriteManager.getSprite("Toolbar") as Sprite;
				toolbar.x = Settings.GAME_WIDTH;
				toolbar.y = 80;
				Sprite(toolbar.getChildByName("fastForward")).mouseChildren = false;
				
				toolbar.name = "toolbar";			
				menus.addChild(toolbar);
				
				selectedTool = "standard";
				Sprite(toolbar.getChildByName("sound")).mouseChildren = false;
				
				
				var selectedHighlight:MovieClip = MovieClip(toolbar.getChildByName("selected"));
				selectedHighlight.mouseEnabled = false;
				toolbar.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
					{
						if (evt.target == toolbar)
							return;
							
							
						if (evt.target.name == "menu")
						{						
							trace("show main menu");
							showMainMenu();
							dispatchEvent(new Event(PlayWithYourPeas.PAUSE_GAME));
						}else if (evt.target.name == "sound")
						{
							if (evt.target.soundOn.visible)
							{
								evt.target.soundOn.visible = false;
								SoundManager.getInstance().pauseAllSounds(true);
								Settings.SOUND_VOLUME = 0;
							}else
							{
								evt.target.soundOn.visible = true;
								SoundManager.getInstance().playAllSounds(true);
								Settings.SOUND_VOLUME = 1;
							}
						}else if (evt.target.name == "reset")
						{
							showResetMenu();
						}else if (evt.target.name == "fastForward")
						{
							var  stats:GameStats = GameStats.getInstance();
							if (stats.currentGameSpeed.value == 1)
							{	
								stats.currentGameSpeed.value = Settings.FAST_FORWARD_SPEED;
								evt.target.getChildByName("slowDown").alpha = 100;
							}else
							{
								stats.currentGameSpeed.value = 1;
								evt.target.getChildByName("slowDown").alpha = 0;
							}
						}else
						{
							selectedTool = evt.target.name;
							selectedHighlight.x = evt.target.x;
							selectedHighlight.y = evt.target.y;
							if (evt.target.name == "deleteTool")
							{
								showDeletePointer();
							}else
							{
								showStandardPointer();
							}
						}
						evt.stopPropagation();
					});
				stage.addEventListener(MouseEvent.CLICK, function(evt:Event):void
					{
						var toolPlaceEvent:PWYPEvent = new PWYPEvent(GameUI.ON_PLACE_TOOL);
						toolPlaceEvent.data = {x:mouseX, y:mouseY, tool:selectedTool};
						dispatchEvent(toolPlaceEvent);
					});
					
					
				var onMouseOutFastForward:Function = function(evt:Event):void
				{
					toolbar.getChildByName("fastForward").removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutFastForward);
					Sprite(toolbar.getChildByName("fastForward")).getChildByName("fastForwardLabel").alpha = 0;
				}
				toolbar.getChildByName("fastForward").addEventListener(MouseEvent.MOUSE_OVER, function(evt:Event):void
				{
					Sprite(toolbar.getChildByName("fastForward")).getChildByName("fastForwardLabel").alpha = 1;
					toolbar.getChildByName("fastForward").addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFastForward);
				});
				startButton = new StartButton();
				startButton.visible = false;
				startButton.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
					{
						evt.stopPropagation();
						dispatchEvent(new Event(GameUI.RUN_TEST));
					});
				startButton.x = -405.05 //Settings.GAME_HEIGHT - startButton.height - 5;
				startButton.y = 380.35 //-Settings.GAME_WIDTH / 2 - startButton.width / 2;
				toolbar.addChild(startButton);
				
				
				stopButton = new StopButton();
				stopButton.visible = false;
				stopButton.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
					{
						evt.stopPropagation();
						dispatchEvent(new Event(GameUI.END_TEST));
					});
				stopButton.x = -405.05 //Settings.GAME_HEIGHT - startButton.height - 5;
				stopButton.y = 380.35 //-Settings.GAME_WIDTH / 2 - startButton.width / 2;
				toolbar.addChild(stopButton);
			}
			
		}
		public function selectTool(toolname:String):void
		{
			selectedTool = toolname;
			var selectedHighlight:MovieClip = MovieClip(toolbar.getChildByName("selected"));
			selectedHighlight.x = toolbar.getChildByName(toolname).x;
			selectedHighlight.y = toolbar.getChildByName(toolname).y;
			if (toolname == "deleteTool")
			{
				showDeletePointer();
			}else
			{
				showStandardPointer();
			}
}
		public function hideAllTools():void
		{
			var tools:Array = new Array("standard", "gel", "leftRamp", "rightRamp", "topLeftRamp", "topRightRamp", "spring");
			for (var i:int = 0; i < tools.length; i++)
			{
				toolbar.getChildByName(tools[i]).visible = false;
			}
		}
		public function showResetMenu():void
		{
			
			//just reset without showing dialog
			dispatchEvent(new Event(ON_RESET_LEVEL));
			
			return;
			
			// this code will show an Are you sure dialog. Removed during testing to see if users like the quick reset better.
			var resetDialog:ResetMenu = new ResetMenu();
			applyDialogFilter(resetDialog)
			resetDialog.name = "resetDialog";
			resetDialog.x = Settings.GAME_WIDTH / 2;
			resetDialog.y = -resetDialog.height;
			Tweener.addTween(resetDialog, { y:Settings.GAME_HEIGHT / 2, time:1, transition:"easeOutBounce" } );
			var closeDialog:Function = function(evt:MouseEvent):void
			{
				dispatchEvent(new Event(UNPAUSE_GAME));
				menus.removeChild(resetDialog);
				evt.stopPropagation();
			}
			resetDialog.ok.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
			{
				closeDialog(evt);
				dispatchEvent(new Event(ON_RESET_LEVEL));
				
				
			});
			dispatchEvent(new Event(PAUSE_GAME));
			resetDialog.cancel.addEventListener(MouseEvent.CLICK, closeDialog);
			menus.addChild(resetDialog );
			
		}
		public function showTools(tools:Array):void
		{
			for (var i:int = 0; i < tools.length; i++)
			{
				toolbar.getChildByName(tools[i]).visible = true;
			}
		}
		public function getSelectedTool():String
		{
			return selectedTool;
		}
		
		
		public function showScoreboard():void
		{
			if (toolbars.getChildByName("scoreboard") == null)
			{
				var scoreboard:Sprite = Sprite(SpriteManager.getSprite("Scoreboard"));
				scoreboard.name = "scoreboard";
				scoreboard.getChildByName("smallLogo").filters = [new GlowFilter(0xF9FED7, .8, 5, 5, 2, 1, false, false)];			
				toolbars.addChild(scoreboard );
				TextField(scoreboard.getChildByName("time")).visible = false;
			}
		}
		
		
		public function updateScoreboard():void
		{
			var scoreboard:Sprite = Sprite(toolbars.getChildByName("scoreboard"));
			var time:Number = GameStats.getInstance().levelTime.value / 1000
			
			var seconds:int = time % 60;
			var minutes:int = (time / 60)%60;
			var hours:int = minutes / 60;
			TextField(scoreboard.getChildByName("time")).text = (hours == 0?"":(hours < 10?"0" + hours:hours.toString()) + ":" ) + 
																(minutes < 10?"0" + minutes:minutes.toString()) + ":" +
																(seconds < 10?"0" + seconds:seconds.toString());
			TextField(scoreboard.getChildByName("score")).text = GameStats.getInstance().happyPoints.value.toString();
			
		}
		public function getScoreboard():Sprite
		{
			return Sprite(toolbars.getChildByName("scoreboard"));
		}
		
		public function showEndOfLevelMenu(nextLevel:Function, tryAgain:Function, onBeginSelectedLevel:Function):void
		{
			var endMenu:EndOfLevelMenu = new EndOfLevelMenu();
			applyDialogFilter(endMenu)
			endMenu.name = "endMenu";
			endMenu.x = Settings.GAME_WIDTH / 2;
			endMenu.y = -endMenu.height;
			Tweener.addTween(endMenu, { y:Settings.GAME_HEIGHT / 2, time:1, transition:"easeOutBounce" } );
			TextField(endMenu.getChildByName("totalPoints")).text = GameStats.getInstance().happyPoints.value.toString();
			
			endMenu.leaveComment.addEventListener(MouseEvent.CLICK, function(evt:Event):void
				{
					showCommentBox();				
				});
			//TextField(endMenu.getChildByName("timePoints")).text =  GameStats.getInstance().levelTime.value + "";
			var score:MochiDigits = GameStats.getInstance().happyPoints;
			
			if (GameStats.getInstance().happyPointsPerLevel[GameStats.getInstance().currentLevelIndex]  == undefined ||
				GameStats.getInstance().happyPointsPerLevel[GameStats.getInstance().currentLevelIndex] < score)
				GameStats.getInstance().happyPointsPerLevel[GameStats.getInstance().currentLevelIndex] = score;
				
			SimpleButton(endMenu.getChildByName("nextLevel")).addEventListener(MouseEvent.CLICK, nextLevel);
			SimpleButton(endMenu.getChildByName("tryAgain")).addEventListener(MouseEvent.CLICK, tryAgain);
			
			
			if (GameStats.getInstance().happyPoints.value >= GameStats.getInstance().currentLevel.targetScore.value)
			{
				
				
				var pea:PeaStandard = PeaStandard(endMenu.getChildByName("pea"));
				pea.bandana.visible = true;
				pea.bandana.alpha = 1;
				var band:MovieClip = pea.bandana.getChildByName("bandColor") as MovieClip;
				var newColorTransform:ColorTransform = band.transform.colorTransform;
				if (GameStats.getInstance().happyPoints.value >= GameStats.getInstance().currentLevel.gold.value)
				{
					newColorTransform.color = 0x3A3B32;
				}else if (GameStats.getInstance().happyPoints.value >= GameStats.getInstance().currentLevel.silver.value)
				{
					newColorTransform.color = 0x0732CE;
				}else 
				{
					newColorTransform.color = 0xF9FED7;
				}
				
				band.transform.colorTransform = newColorTransform;		
			}
			
			//var levelSelection:com.mccullick.pwyp.assets.LevelMenu = new com.mccullick.pwyp.assets.LevelMenu();
			menus.addChild(endMenu );
			
			for (var iLevel:int = 1; iLevel <= 12; iLevel++)
			{
				var levelBox:LevelBox = LevelBox(endMenu.levelMenu.getChildByName("level" + iLevel));
				levelBox.gotoAndStop(1);
				levelBox.mouseChildren = false;
				
				
				if (iLevel == 1 || GameStats.getInstance().happyPointsPerLevel[iLevel - 2] != undefined)
				{
					levelBox.addEventListener(MouseEvent.CLICK, function(evt:Event):void
					{
						GameStats.getInstance().currentLevelIndex = Number(evt.target.level.text)-1;
						onBeginSelectedLevel();
					});
					var levelScore:Number ;
					if (GameStats.getInstance().happyPointsPerLevel[iLevel - 1] != undefined)
					{
						levelScore = Number(GameStats.getInstance().happyPointsPerLevel[iLevel - 1].value);
					}
					levelBox.gotoAndStop(2);
					if (levelScore >= Settings.levels[iLevel-1].silver.value)
					{
						levelBox.blue.visible = true;
					}else 
					{
						levelBox.blue.visible = false;
					}
					if (levelScore >= Settings.levels[iLevel-1].gold.value)
					{
						levelBox.black.visible = true;
					}else
					{
						levelBox.black.visible = false;
					}
				}								
				levelBox.level.text = iLevel + "";
			}
			
		}
		public function hideEndOfLevelMenu():void
		{
			menus.removeChild(menus.getChildByName("endMenu"));
		}
		
		public function get toolbar():Sprite { return _toolbar; }
		
		public function set toolbar(value:Sprite):void 
		{
			_toolbar = value;
		}
		
		
		public function showEditor():void
		{
			var editor:PWYPEditor = new PWYPEditor(showMainMenu);
			menus.addChild(editor);
		}
		
		public function showCredits():void
		{
			var credits:Sprite = SpriteManager.getSprite("CreditsDialog") as Sprite;
			credits.x = Settings.GAME_WIDTH / 2 - credits.width / 2;
			credits.y = Settings.GAME_HEIGHT / 2 - credits.height / 2;
			var okBtn:SimpleButton = SimpleButton(credits.getChildByName("okBtn"));
			okBtn.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				evt.stopPropagation();
				menus.removeChild(credits);
			});
			applyDialogFilter(credits);
			menus.addChild(credits);
		}
		public function showCommentBox():void
		{
			/*
			var commentBox:CommentDialog = new CommentDialog();
			menus.addChild(commentBox);
			commentBox.okBtn.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				if (MochiBot.checkCommentLimiter(Settings.MOCHIBOT_ID, 30))
				{
					var comment:String = commentBox.commentBox.text;
					if (comment != "")
					{
						comment += "                         fun: " + funValue + " level: " + GameStats.getInstance().currentLevelIndex + " " + GameStats.getInstance().currentLevel.title;
					
						MochiBot.submitComment(comment, Settings.MOCHIBOT_ID);
					}
				}
				menus.removeChild(commentBox);
			});
			
			commentBox.cancelBtn.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				menus.removeChild(commentBox);
			});
			*/
		}
		private static var funValue:Number = 0;
		
		/**
		 * Send the fun rating to tracker. The code for sending tracking has
		 * been removed. 
		 * http://philprogramming.blogspot.com/2009/08/using-google-events-to-track-fun-rating.html
		 */
		public function showFunRating():void
		{
			var funRating:FunRating = new FunRating();
			menus.addChild(funRating);
			funRating.leaveComment.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				showCommentBox();				
			});
			funRating.fun1.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				//Send the fun value 1 to the tracker
				funValue = 1;
				menus.removeChild(funRating);
			});
			funRating.fun2.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{				
				//Send the fun value 2 to the tracker
				funValue = 2;
				menus.removeChild(funRating);
			});
			funRating.fun3.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				
				//Send the fun value 3 to the tracker
				funValue = 3;
				menus.removeChild(funRating);
			});
		
			funRating.fun4.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				
				//Send the fun value 4 to the tracker
				funValue = 4;
				menus.removeChild(funRating);
			});
			funRating.fun5.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{
				
				//Send the fun value 5 to the tracker
				funValue = 5;
				menus.removeChild(funRating);
			});
		}
		
		private function applyDialogFilter(mc:Sprite):void
		{
			mc.filters = [new DropShadowFilter(4, 45, 0, .5)];			
		}
		
		private function enableButton(btn:SimpleButton):void
		{
			btn.mouseEnabled = true;
			btn.filters = [];
		}
		
		private function disableButton(btn:SimpleButton):void
		{
			btn.mouseEnabled = false;
			btn.filters = [new GlowFilter(0x333333, .5, 2, 2, 5, 1, true, true)];
		}
	}
}