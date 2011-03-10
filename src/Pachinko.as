package  
{
	 import com.mccullick.utils.SpriteManager;
	 import flash.display.Bitmap;
	 import flash.display.BitmapData;
	 import flash.display.Sprite;
	 import flash.geom.Matrix;
	 import org.flintparticles.common.actions.Age;

  import org.flintparticles.common.counters.TimePeriod;
  import org.flintparticles.common.displayObjects.Dot;
  import org.flintparticles.common.initializers.CollisionRadiusInit;
  import org.flintparticles.common.initializers.SharedImage;
  import org.flintparticles.common.initializers.Lifetime;

  import org.flintparticles.twoD.actions.Accelerate;
  import org.flintparticles.twoD.actions.Collide;
  import org.flintparticles.twoD.actions.CollisionZone;
  import org.flintparticles.twoD.actions.DeathZone;
  import org.flintparticles.twoD.actions.Move;
  import org.flintparticles.twoD.emitters.Emitter2D;
  import org.flintparticles.twoD.initializers.Position;
  import org.flintparticles.twoD.initializers.Velocity;
  import org.flintparticles.twoD.zones.DiscZone;
  import org.flintparticles.twoD.zones.LineZone;
  import org.flintparticles.twoD.zones.PointZone;
  import org.flintparticles.twoD.zones.RectangleZone;
  import org.flintparticles.twoD.particles.Particle2DUtils;


  import flash.geom.Point;

  
  public class Pachinko extends Emitter2D 
  {
    public function Pachinko()
    {
		
     
	
			
	
	  var standardBlock:Sprite = SpriteManager.getSprite("standardBlock") as Sprite;
			var mat:Matrix = new Matrix();
			mat.translate(0, standardBlock.height);

			var bitmapData:BitmapData = new BitmapData(standardBlock.width, standardBlock.height);
			bitmapData.draw(standardBlock, mat);
			//this.addChild(bitmap);
			 
      var particles:Array = Particle2DUtils.createRectangleParticlesFromBitmapData( bitmapData, 10, this.particleFactory, 56, 47 );
	  trace(particles.length);
      addExistingParticles( particles, true );

      //addInitializer( new SharedImage( new Dot( 4 ) ) );
      addInitializer( new CollisionRadiusInit( 5 ) );
      addInitializer( new Position( new LineZone( new Point( 130, -5 ), new Point( 350, -5 ) ) ) );
      addInitializer( new Velocity( new DiscZone( new Point( 0, 100 ), 20 ) ) );
       addInitializer( new Lifetime( 1, 5 ) );
      
      addAction( new Age() );

      addAction( new Move() );
      addAction( new Accelerate( 0, -10 ) );
      addAction( new Collide() );
      addAction( new DeathZone( new RectangleZone( 0, 425, 480, 450 ) ) );
      addAction( new CollisionZone( new DiscZone( new Point( 240, 205 ), 242 ), 0.5 ) );
	  addAction(new CollisionZone(new RectangleZone(150, 150, 400, 300)));
    }
    
    public function addPin( x:Number, y:Number ):void
    {
     // addAction( new CollisionZone( new PointZone( new Point( x, y ) ), 1 ) );
    }
  }
}