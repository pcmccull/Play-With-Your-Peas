package
{
  import com.mccullick.utils.SpriteManager;
  import flash.display.BitmapData;
  import flash.events.Event;
  import flash.geom.Matrix;
  import org.flintparticles.twoD.actions.DeathZone;
  import org.flintparticles.twoD.actions.Explosion;
  import org.flintparticles.twoD.actions.Move;
  import org.flintparticles.twoD.emitters.Emitter2D;
  import org.flintparticles.twoD.particles.Particle2DUtils;
  import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
  import org.flintparticles.twoD.zones.RectangleZone;
import org.flintparticles.twoD.actions.Accelerate;
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.text.TextField;

  public class ExplosionAnim extends Sprite
  {
    // width:384 height:255
  

    private var emitter:Emitter2D;
    private var bitmap:Bitmap;
    private var renderer:DisplayObjectRenderer;
    
    public function ExplosionAnim()
    {
      var txt:TextField = new TextField();
      txt.text = "Click on the image.";
      txt.textColor = 0xFFFFFF;
      addChild( txt );

      var standardBlock:Sprite = SpriteManager.getSprite("standardBlock") as Sprite;
		
	  var mat:Matrix = new Matrix();
			mat.translate(0, standardBlock.height);

			var bitmapData:BitmapData = new BitmapData(standardBlock.width, standardBlock.height);
			bitmapData.draw(standardBlock, mat);
      
      emitter = new Emitter2D();
      emitter.addAction( new DeathZone( new RectangleZone( -5, -5, 505, 355 ), true ) );
      emitter.addAction( new Move() );
	  
	 
      var particles:Array = Particle2DUtils.createRectangleParticlesFromBitmapData( bitmapData, 10, emitter.particleFactory, 56, 47 );
      emitter.addExistingParticles( particles, false );
      
      renderer = new DisplayObjectRenderer();
      addChild( renderer );
      renderer.addEmitter( emitter );
      emitter.start();
      this.addEventListener(Event.ADDED_TO_STAGE, function(evt:Event):void
		{
		stage.addEventListener( MouseEvent.CLICK, explode, false, 0, true );
		});
    }
    
    private function explode( ev:MouseEvent ):void
    {
      var p:Point = renderer.globalToLocal( new Point( ev.stageX, ev.stageY ) );
	   emitter.addAction( new Accelerate( 0, 10 ) );
      emitter.addAction( new Explosion( 1, p.x, p.y, 70 ) );
    }
  }
}