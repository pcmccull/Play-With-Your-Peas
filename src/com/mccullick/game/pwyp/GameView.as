package com.mccullick.game.pwyp 
{
	import caurina.transitions.Tweener;
	import com.mccullick.events.DataEvent;
	import com.mccullick.utils.SpriteManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.text.TextField;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.twoD.actions.Friction;
	import org.flintparticles.twoD.actions.Rotate;
	import org.flintparticles.twoD.activities.RotateEmitter;
	import org.flintparticles.twoD.particles.ParticleCreator2D;
	import org.flintparticles.twoD.renderers.BitmapRenderer;
	
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.particles.Particle2DUtils;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	import org.flintparticles.twoD.actions.Explosion;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.actions.Accelerate;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.events.EmitterEvent;
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.initializers.CollisionRadiusInit;
    import org.flintparticles.twoD.actions.Collide;
    import org.flintparticles.twoD.actions.CollisionZone;
	import org.flintparticles.twoD.zones.RectangleZone;
	 
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class GameView extends Sprite
	{
		
		private var peas:Sprite;
		private var blocks:Sprite;
		private var specialItems:Sprite;
		private var alerts:Sprite;
		private var overBlock:Block = null;
		private var clouds:Sprite;
		private var cloudList:Array;
		
		public function GameView() 
		{
			
		}
		public function init():void
		{ 
			
			cloudList = new Array();
			clouds = new Sprite();
			
			this.addChild(clouds);
			blocks = new Sprite();
		
			blocks.y -= 12 * GameStats.getInstance().currentLevel.scale;		
			this.y = Settings.modifiedGameViewOffsetY;			
			this.addChild(blocks);
			specialItems = new Sprite();
			this.addChild(specialItems);
			peas = new Sprite();
			peas.y -= 6;
			this.addChild(peas);
			alerts = new Sprite();
			this.addChild(alerts);
			stage.addEventListener(PlayWithYourPeas.UPDATE_MULTIPLIER_EVENT, onShowMultiplier);
			
			
		}
		private function onShowMultiplier(evt:DataEvent):void
		{
			var multiplierSprite:Sprite = SpriteManager.getSprite("MultiplierText") as Sprite;
			TextField(multiplierSprite.getChildByName("multiplier")).text = evt.data.multiplier;
			multiplierSprite.x = evt.data.pea.x;
			multiplierSprite.y = evt.data.pea.y - 20;
			this.addChild(multiplierSprite);
			var thisObj:GameView = this;
			Tweener.addTween(multiplierSprite,  { alpha:0, y:multiplierSprite.y - 30, delay:1.5, time:.5, onComplete:function():void
				{
					thisObj.removeChild(multiplierSprite);
				}});
			
		}
		
		/**
		 * Show the hover graphic for placing a new block
		 * @param	block
		 * @param	x
		 * @param	y
		 */
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
		/**
		 * hide the hover graphic for placing a new block
		 */
		public function hideOverBlock():void
		{			
			if (overBlock != null)
				overBlock.alpha = 0;
		}
		
		/**
		 * Add a new pea to the game view
		 * @param	pea
		 */
		public function addPea(pea:Pea):void
		{
			peas.addChild(pea);
			pea.scaleX = GameStats.getInstance().currentLevel.scale;
			pea.scaleY = GameStats.getInstance().currentLevel.scale;
			
		}
		/**
		 * Remove a pea from the game view
		 * @param	pea
		 */
		public function removePea(pea:Pea):void
		{
			peas.removeChild(pea);
		}
		
		/**
		 * Kill a pea, show the pea killed animation
		 * @param	pea
		 */
		public function killPea(pea:Pea, showGhost:Boolean=true):void
		{
			var thisObj:GameView = this;
			if (showGhost)
			{
				var ghostPea:Sprite = SpriteManager.getSprite("PeaGhost")  as Sprite;
				ghostPea.scaleX = GameStats.getInstance().currentLevel.scale;
				ghostPea.scaleY = GameStats.getInstance().currentLevel.scale;
				ghostPea.x = pea.x;
				ghostPea.y = pea.y;
				this.addChild(ghostPea);
				
				Tweener.addTween(ghostPea, { y:pea.y - 40, alpha:.2, time:2, onComplete:function():void
						{
							thisObj.removeChild(ghostPea);
							thisObj.removePea(pea);
				} } );
			}else
			{
				pea.visible = true;
				pea.alpha = 1;
				Tweener.addTween(pea, {scaleX:.1, scaleY:.1, alpha:.2, time:2, onComplete:function():void
						{
							thisObj.removePea(pea);
				} } );
			}
		}
		
		/**
		 * Add a new block to the game view
		 * @param	block
		 * @param	x
		 * @param	y
		 */
		public function addBlock(block:Block, x:Number, y:Number):void
		{
			
			
			block.sprite = SpriteManager.getSprite(block.blockId);
			trace(block.sprite);
			block.scaleX = GameStats.getInstance().currentLevel.scale;
			block.scaleY = GameStats.getInstance().currentLevel.scale;
			block.alpha = .2;
			Tweener.addTween(block, { alpha:1, delay:Settings.ADD_BLOCK_DELAY/4*3,transition:"easeInSine", time:Settings.ADD_BLOCK_DELAY/4 } );
			var blockLocation:Point = GameModel.convertBlockToGameCoord(x, y);
			
			block.x = blockLocation.x-(Settings.BLOCK_WIDTH*GameStats.getInstance().currentLevel.scale)/2;
			block.y = blockLocation.y+(Settings.BLOCK_HEIGHT*GameStats.getInstance().currentLevel.scale)/2;
			
			blocks.addChild(block);
			/*if (y == 0)
			{
				var shadow:DisplayObject = SpriteManager.getSprite("BlockShadow");
				shadow.alpha = .7;
				shadow.x += block.width / 2;
				block.addChildAt(shadow, 0);
			}*/
			
		}
		
		public function addSpecialItem(item:SpecialItem, x:Number, y:Number):void
		{
			var sprite:Sprite = item.createSprite();
			var blockLocation:Point = GameModel.convertBlockToGameCoord(x, y);
			sprite.x = blockLocation.x-(Settings.BLOCK_WIDTH*GameStats.getInstance().currentLevel.scale)/2;
			sprite.y = blockLocation.y + (Settings.BLOCK_HEIGHT * GameStats.getInstance().currentLevel.scale) / 2;
			sprite.scaleX = GameStats.getInstance().currentLevel.scale;
			sprite.scaleY = GameStats.getInstance().currentLevel.scale;
			specialItems.addChild(sprite);
		}
		public function removeSpecialItem(item:SpecialItem):void
		{
			specialItems.removeChild(item.getSprite());
		}
		
		public function removeAllSpecialItems():void
		{
			while (specialItems.numChildren > 0)
			{
				specialItems.removeChildAt(0);
			}
		}
		
		public function showPeaScored(score:Number):void
		{
			var scoreOutput:Sprite = new Sprite();
			var scoreStr:String = "+" + score.toString();
			
			for (var i:Number = 0; i < scoreStr.length; i++)
			{
				var scoreText:Sprite = SpriteManager.getSprite("ScoreText") as Sprite;
				var scoreTF:TextField = TextField(scoreText.getChildByName("title"));
				scoreTF.autoSize = "left";
				scoreTF.text = scoreStr.charAt(i);
				scoreText.x = scoreOutput.width + 4;
				scoreText.y -= 100;
				scoreText.alpha = 0;
				Tweener.addTween(scoreText, { y:scoreText.y + 100, alpha:1, time:.5, delay:i * .2 } );
				scoreOutput.addChild(scoreText);
			}
			scoreOutput.x = Settings.PLAY_AREA_WIDTH / 2 ;
			scoreOutput.y -= 300;
			Tweener.addTween(scoreOutput, { _saturation:0, alpha:0, y: -500, scaleX:.2, scaleY:.2, delay:1.5, time:.8, onComplete:function():void
				{
					alerts.removeChild(scoreOutput);
			}});
			alerts.addChild(scoreOutput);
			
		}
		
		/**
		 * Remove a block from the game view
		 * @param	block
		 */
		public function removeBlock(block:Block):void
		{
			var mat:Matrix = new Matrix();
			mat.translate(0, block.height);
			
			var bitmapData:BitmapData = new BitmapData(block.width, block.height);
			bitmapData.draw(block, mat);
			
			var emitter:Emitter2D = new Emitter2D();
			
			emitter.addAction( new Move() );
			emitter.addAction( new Age() );
			emitter.addInitializer( new Lifetime( 2, 3 ) );
			var particles:Array = Particle2DUtils.createRectangleParticlesFromBitmapData( bitmapData, block.width/7, emitter.particleFactory, block.x, block.y-block.height );
			emitter.addExistingParticles( particles, true );
	
			var renderer:DisplayObjectRenderer = new DisplayObjectRenderer();
			

			addChild( renderer );
			renderer.addEmitter( emitter );
			
			var p:Point =  new Point( mouseX, mouseY ) ;
			emitter.addAction( new Accelerate( 0, 500 ) );
			
			emitter.addInitializer( new CollisionRadiusInit( 4 ) );
			emitter.addActivity(new RotateEmitter(.1));
			emitter.addAction(new CollisionZone(new RectangleZone(0, 10, Settings.GAME_WIDTH, 20)));
			emitter.addAction(new CollisionZone(new RectangleZone(-60, -Settings.GAME_HEIGHT, -50, 0)));
			emitter.addAction(new CollisionZone(new RectangleZone(Settings.GAME_WIDTH, -Settings.GAME_HEIGHT, Settings.GAME_WIDTH+10, 0)));
			emitter.addAction(new Friction(300));
			emitter.addAction(new Fade());
			
			for (var i:int = 0; i < blocks.numChildren; i++)
			{
				
				var b:DisplayObject = blocks.getChildAt(i);
				if (b != block)
					emitter.addAction(new CollisionZone(new RectangleZone(b.x,b.y-block.height, b.x+block.width,   (b.y+b.height)-15-block.height)));
			}

			emitter.addAction( new Explosion( 4, block.x + block.width/2, block.y- block.height/2+10, 100 ) );
			emitter.start();
			block.visible = false;
			var thisObj:GameView = this;
			//when the animation finishes delete the block
			blocks.removeChild(block);
			var onAnimCompleted:Function = function(evt:Event):void
			{
				emitter.removeEventListener(EmitterEvent.EMITTER_EMPTY, onAnimCompleted);
				thisObj.removeChild(renderer);				
				
			}
			emitter.addEventListener( EmitterEvent.EMITTER_EMPTY, onAnimCompleted);
		}
		
		public function cleanup():void
		{
			if (blocks  != null)
			{
				this.removeChild(blocks);
				this.removeChild(peas);
				this.removeChild(clouds);
				this.cloudList = new Array();
				this.overBlock = null;
				this.removeChild(specialItems);
			}
		}
		
		
		/**
		 * Update the game view
		 * @param	dt
		 */
		public function update(dt:Number):void
		{
			//add cloud			
			if (Math.random() < .0004*dt)
				addCloud();
				
			//move the clouds
			var removeClouds:Array = new Array();
			for (var i:Number = 0; i < cloudList.length; i++)
			{
				cloudList[i].x += cloudList[i].speed * dt;
				if (cloudList[i].x > Settings.GAME_WIDTH + 100)
				{
					removeClouds.push(i);
				}
			}
			
			for (i = removeClouds.length - 1; i >= 0; i--)
			{
				clouds.removeChild(cloudList[removeClouds[i]]);
				cloudList.splice(removeClouds[i], 1);
			}
			
			
		}
		
		private function addCloud():void
		{
			//get a cloud number between 1 and 3
			var cloudType:int = Math.min(3, Math.floor(Math.random() * 3) + 1);
			
			var cloud:Sprite = new Cloud(SpriteManager.getSprite("Cloud" + cloudType), Math.random() * .2 + .02);
			cloud.x = -cloud.width;
			cloud.y = -Settings.modifiedGameViewOffsetY + Math.random() * 200*(GameStats.getInstance().currentLevel.scale*GameStats.getInstance().currentLevel.scale);
			clouds.addChild(cloud);
			cloudList.push(cloud);
		}
		
		private function stageXToLocal(stageX:Number):Number
		{
			return stageX - this.x;
		}
		
		private function stageYToLocal(stageY:Number):Number
		{
			return stageY - this.y;
		}
		
		public function showConfetti(color:Number, x:Number, y:Number):void
		{
			
			
			var renderer:BitmapRenderer = new BitmapRenderer( new Rectangle( -40, -500, 700, 600 ) );
			var emitter:Emitter2D = new Firework(color);
			renderer.addFilter( new BlurFilter( 2, 2, 1 ) );
			renderer.addFilter( new ColorMatrixFilter( [ 1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.95,0 ] ) );
			renderer.addEmitter( emitter );
			addChild( renderer );
			 
			emitter.x = 300;
			emitter.y = -400;
			emitter.start();
			
			var cleanup:Function = function(evt:EmitterEvent):void
				{
					emitter.stop();
					emitter.removeEventListener( EmitterEvent.EMITTER_EMPTY, cleanup);
					// remove all particles from the emitter - returning them to the particle factory
					
					emitter.killAllParticles();
					// clear all particles from the particle factory
					
					ParticleCreator2D( emitter.particleFactory ).clearAllParticles();
					// remove the reference to the emitter
					emitter = null;
					// remove the renderer from the stage
					removeChild( renderer );
					// remove the reference to the renderer
					renderer = null;

					// force the garbage collector to do its thing now - required for testing
					try {
					new LocalConnection().connect('foo');
					new LocalConnection().connect('foo');
					} catch (e:*) {}
				}
			emitter.addEventListener( EmitterEvent.EMITTER_EMPTY, cleanup);
   
		}
	
		
		
	}
	
}
import flash.display.DisplayObject;
import flash.display.Sprite;

class Cloud extends Sprite {
	public var speed:Number;
	public function Cloud(sprite:DisplayObject, speed:Number)
	{
		this.speed = speed;
		this.addChild(sprite);
	}
}