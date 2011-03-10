package com.mccullick.game.pwyp.editor 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.ScrollPane;
	import com.mccullick.game.pwyp.Block;
	import com.mccullick.game.pwyp.GameModel;
	import com.mccullick.game.pwyp.GameStats;
	import com.mccullick.game.pwyp.GameView;
	import com.mccullick.game.pwyp.Level;
	import com.mccullick.game.pwyp.Settings;
	import com.mccullick.games.pwyp.assets.toolSelected;
	import com.mccullick.pwyp.assets.EdLevelSettings;
	import com.mccullick.pywp.assets.ExitButton;
	import com.mccullick.utils.SpriteManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import mochi.as3.MochiDigits;
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class PWYPEditor extends Sprite
	{
		private var levelSettings:EdLevelSettings;
		private var scaleSetting:ComboBox;
		
		private var onCloseEditor:Function;
		private var model:GameModel;
		private var view:GameView;
		private var blocks:Sprite;
		private var selectedBlock:Block;
		private var level:Level;
		
		
		public function PWYPEditor(onCloseEditor:Function) 
		{
			this.onCloseEditor = onCloseEditor;
			//show the dialog for level settings
			levelSettings = new EdLevelSettings();
			levelSettings.x = Settings.GAME_WIDTH / 2 - levelSettings.width / 2;
			levelSettings.y = Settings.GAME_HEIGHT  / 2 - levelSettings.height / 2;
			levelSettings.okBtn.addEventListener(MouseEvent.CLICK, createLevel);
			scaleSetting = new ComboBox(levelSettings, levelSettings.getChildByName("scaleInputPos").x, levelSettings.getChildByName("scaleInputPos").y, "Small", ["XSmall", "Small", "Medium", "Large", "XLarge"]);
			
			this.addChild(levelSettings);
			
			var exitBtn:ExitButton = new ExitButton();
			exitBtn.x = Settings.GAME_WIDTH - exitBtn.width-15;
			exitBtn.y = Settings.GAME_HEIGHT - exitBtn.height-15;
			exitBtn.addEventListener(MouseEvent.CLICK, closeEditor);
			this.addChild(exitBtn);
		
			
			
		}
		private function closeEditor(evt:Event):void
		{
			this.parent.removeChild(this);
			onCloseEditor();
		}
		
		private function createLevel(evt:Event):void
		{
			var scale:Number;
			if (scaleSetting.selectedItem != null)
			{
				scale = Settings.LEVEL_SCALES[String(scaleSetting.selectedItem).toLowerCase()];
			}else
			{
				scale = Settings.LEVEL_SCALES.small;
			}
			level = new Level(levelSettings.titleInput.text, ["Standard"], [], new Point(0, 0), new Point(4, 0), new MochiDigits(Number(levelSettings.goalInput.text)), new MochiDigits(1), "default", scale, [], new MochiDigits(Number(levelSettings.bronzeInput.text)), new MochiDigits(Number(levelSettings.silverInput.text)), new MochiDigits(Number(levelSettings.goldInput.text)));
			
			
			GameStats.getInstance().currentLevelIndex = -1;
			GameStats.getInstance().currentLevel = level;
			levelSettings.visible = false;
			//load the available blocks
			
			//load the available special items
			
			
			
			blocks = new Sprite();
		
			blocks.y -= 12 * GameStats.getInstance().currentLevel.scale;		
			this.y = Settings.modifiedGameViewOffsetY;			
			this.addChild(blocks);
			
			var block2:Block = Settings.blocks.standard.cloneWithLocation(0, 0);
			
			addBlock(block2, 0, 0);
			
			
			var pane:ScrollPane = new ScrollPane(this, 0, -this.y);
			pane.setSize(Settings.GAME_WIDTH, Settings.BLOCK_HEIGHT + 20);
			var lastX:Number = 0;
			var selectRectangle:toolSelected = new toolSelected();
			selectRectangle.scaleX = selectRectangle.scaleY = .7;
			selectRectangle.alpha = .6;
			for (var blockType:Object in Settings.blocks)				
			{
				var block:Block = Settings.blocks[blockType].cloneWithLocation(5, 5);
				block.sprite = SpriteManager.getSprite(block.blockId);
				block.scaleX = block.scaleY = .5
				
				block.x = lastX+10;
				block.y = 50;
				lastX = block.x + block.width;
				pane.content.addChild(block);
				block.addEventListener(MouseEvent.CLICK, function(evt:Event):void
				{					
					selectedBlock = evt.currentTarget as Block;
					selectRectangle.x = evt.currentTarget.x+block.width/2;					
				});
				
			}
			selectedBlock = block;
			selectRectangle.x = selectedBlock.x+block.width/2;
			selectRectangle.y = selectedBlock.y-block.height/2;
			pane.addChild(selectRectangle);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onPlaceTool);
		}
		
		private function onPlaceTool(evt:MouseEvent):void
		{
			var clickPoint:Point = GameModel.convertStageToGameCoord(evt.stageX + Settings.BLOCK_WIDTH*GameStats.getInstance().currentLevel.scale/2, evt.stageY);
			var blockPoint:Point = GameModel.convertGameToBlockCoord(clickPoint.x, clickPoint.y);
			addBlock(selectedBlock.cloneWithLocation(blockPoint.x, blockPoint.y), blockPoint.x, blockPoint.y);
		}
		
		private function addBlockById(blockId:String, x:Number, y:Number):void
		{
			/*var block:Block = Settings.blocks[blockType].cloneWithLocation(5, 5);
			block.sprite = SpriteManager.getSprite(block.blockId);
			block.scaleX = block.scaleY = .5
			
			block.x = lastX+10;
			block.y = 50;
			lastX = block.x + block.width;
			pane.content.addChild(block);
			block.addEventListener(MouseEvent.CLICK, function(evt:Event):void
			{					
				selectedBlock = evt.currentTarget as Block;
				selectRectangle.x = evt.currentTarget.x+block.width/2;					
			});*/
		}
		private function addBlock(block:Block, x:Number, y:Number):void
		{
			block.sprite = SpriteManager.getSprite(block.blockId);
			trace(block.sprite);
			block.scaleX = GameStats.getInstance().currentLevel.scale;
			block.scaleY = GameStats.getInstance().currentLevel.scale;
			trace(GameStats.getInstance().currentLevel.scale);
			var blockLocation:Point = GameModel.convertBlockToGameCoord(x, y);
			trace(blockLocation);
			block.x = blockLocation.x-(Settings.BLOCK_WIDTH*GameStats.getInstance().currentLevel.scale)/2;
			block.y = blockLocation.y+(Settings.BLOCK_HEIGHT*GameStats.getInstance().currentLevel.scale)/2;
			
			blocks.addChild(block);
		}
		
		/**
		 * Show the hover graphic for placing a new block
		 * @param	block
		 * @param	x
		 * @param	y
		 */
		private var overBlock:Block;
		public function showOverBlock(block:Block, x:Number, y:Number):void
		{
			
			var bAddBlock:Boolean = overBlock == null;
			
			if (bAddBlock)
			{				
				overBlock = Settings.blocks.standard.clone();
			}
			
				
			if (bAddBlock || overBlock.title != block.title )
			{
				overBlock.title = block.title;
				if (overBlock.sprite != null)
					overBlock.removeChild(overBlock.sprite);
				overBlock.sprite = SpriteManager.getSprite(block.blockId);
				overBlock.scaleX = GameStats.getInstance().currentLevel.scale;
				overBlock.scaleY = GameStats.getInstance().currentLevel.scale;
				
			}
			
			if (bAddBlock)
			{
				blocks.addChild(overBlock);							
			}
			
			var blockLocation:Point = GameModel.convertBlockToGameCoord(x, y);			
			overBlock.x = blockLocation.x-(Settings.BLOCK_WIDTH*GameStats.getInstance().currentLevel.scale)/2;
			overBlock.y = blockLocation.y + (Settings.BLOCK_HEIGHT * GameStats.getInstance().currentLevel.scale) / 2;
			overBlock.alpha = .15;
		}
		
		
		
	}

}