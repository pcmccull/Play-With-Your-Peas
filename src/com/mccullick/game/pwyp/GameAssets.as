package com.mccullick.game.pwyp 
{
	import com.mccullick.utils.SpriteManager;
	import com.reintroducing.sound.SoundManager;
	
	/**
	 * Handle all of the images and sounds
	 * @author Philip McCullick
	 */
	public class GameAssets 
	{
		//graphics
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='background')]
		private const Background:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='pointerStandard')]
		private const PointerStandard:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='pointerDelete')]
		private const PointerDelete:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='mainMenu')]
		private const MainMenu:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='scoreboard')]
		private const Scoreboard:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='PeaGhost')]
		private const PeaGhost:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='AlertNinja')]
		private const AlertNinja:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='AlertTrap')]
		private const AlertTrap:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='AlertFail')]
		private const AlertFail:Class;
	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='toolbar')]
		private const Toolbar:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='FlagPole')]
		private const FlagPole:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='BlockShadow')]
		private const BlockShadow:Class;		
		
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='slimeyBlock')]
		private const SlimeyBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='spikeyBlock')]
		private const SpikeyBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='exitBlock')]
		private const ExitBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='standardBlock')]
		private const StandardBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='gelBlock')]
		private const GelBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='rightRampBlock')]
		private const RightRampBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='leftRampBlock')]
		private const LeftRampBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='topRightRampBlock')]
		private const TopRightRampBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='topLeftRampBlock')]
		private const TopLeftRampBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='entranceBlock')]
		private const EntranceBlock:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='springBlock')]
		private const SpringBlock:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='MultiplierText')]
		private const MultiplierText:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='Star')]
		private const Star:Class;	
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='ScoreText')]
		private const ScoreText:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='Instructions')]
		private const Instructions:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='Cloud1')]
		private const Cloud1:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='Cloud2')]
		private const Cloud2:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='Cloud3')]
		private const Cloud3:Class;
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='coin')]
		private const Coin:Class;
		
		[Embed(source='../../../../assets/pwyp_assets.swf', symbol='creditsDialog')]
		private const CreditsDialog:Class;
		
		
		
		[Embed(source = '../../../../assets/soundEffects/andrew_uhoh.mp3')]
		private var FX_UHOH:Class;
		[Embed(source = '../../../../assets/soundEffects/justin_itsapeasgame.mp3')]
		private var FX_ITS_A_PEAS_GAME:Class;
		[Embed(source = '../../../../assets/soundEffects/andrew_wah.mp3')]
		private var FX_WAH:Class;
		[Embed(source = '../../../../assets/soundEffects/justin_itsatrap.mp3')]
		private var FX_ITS_A_TRAP:Class;
		
		private static var assets:GameAssets;
		public function GameAssets(key:PrivateConstructorKey) 
		{
			var spriteManager:SpriteManager = SpriteManager.getInstance();
			spriteManager.addClass("Background", Background);
			spriteManager.addClass("PointerStandard", PointerStandard);
			spriteManager.addClass("PointerDelete", PointerDelete);
			spriteManager.addClass("MainMenu", MainMenu);
			spriteManager.addClass("Scoreboard", Scoreboard);
			spriteManager.addClass("PeaGhost", PeaGhost);
			spriteManager.addClass("AlertNinja", AlertNinja);
			spriteManager.addClass("AlertTrap", AlertTrap);
			spriteManager.addClass("AlertFail", AlertFail);
			spriteManager.addClass("Toolbar", Toolbar);
			spriteManager.addClass("spikeyBlock", SpikeyBlock);
			spriteManager.addClass("slimeyBlock", SlimeyBlock);
			spriteManager.addClass("exitBlock", ExitBlock);
			spriteManager.addClass("standardBlock", StandardBlock);
			spriteManager.addClass("gelBlock", GelBlock);
			spriteManager.addClass("rightRampBlock", RightRampBlock);
			spriteManager.addClass("leftRampBlock", LeftRampBlock);
			spriteManager.addClass("topRightRampBlock", TopRightRampBlock);
			spriteManager.addClass("topLeftRampBlock", TopLeftRampBlock);
			spriteManager.addClass("entranceBlock", EntranceBlock);
			spriteManager.addClass("springBlock", SpringBlock);
			spriteManager.addClass("BlockShadow", BlockShadow);			
			spriteManager.addClass("FlagPole", FlagPole);
			spriteManager.addClass("MultiplierText", MultiplierText);
			spriteManager.addClass("Star", Star);
			spriteManager.addClass("ScoreText", ScoreText);
			spriteManager.addClass("Instructions", Instructions);
			spriteManager.addClass("Cloud1", Cloud1);
			spriteManager.addClass("Cloud2", Cloud2);
			spriteManager.addClass("Cloud3", Cloud3);
			spriteManager.addClass("Coin", Coin);
			spriteManager.addClass("CreditsDialog", CreditsDialog);
			
			
			
			SoundManager.getInstance().addLibrarySound(FX_UHOH, "fxUhOh");
			SoundManager.getInstance().addLibrarySound(FX_ITS_A_PEAS_GAME, "fxItsAPeasGame");
			SoundManager.getInstance().addLibrarySound(FX_WAH, "fxWah");
			SoundManager.getInstance().addLibrarySound(FX_ITS_A_TRAP, "fxItsATrap");
		}
		
		public static function init():void
		{
			if(assets == null)
				assets = new GameAssets(new PrivateConstructorKey());
			
		}
		
	}
	
}

class PrivateConstructorKey
{
	public function PrivateConstructorKey()
	{
		
	}
}