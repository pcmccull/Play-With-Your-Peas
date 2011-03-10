package com.mccullick.game.pwyp 
{
	import Box2D.Dynamics.b2World;
	import flash.geom.Point;
	import mochi.as3.MochiDigits;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import mochi.as3.MochiScores;
	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class Settings 
	{
		public static var SOUND_VOLUME:Number = 1;
		
		public static var version:Number = 1.0;
		public static var MOCHIBOT_ID:String = "246e7864";
		
		//SETTINGS
		public static const STARTING_LEVEL:Number = 0;
	
		public static const PEA_SPEED:Number = .3;
		public static const PEA_JUMP_SPEED_Y:Number = .3;
		public static const PEA_JUMP_SPEED_X:Number = .4;
		public static const PEA_RADIUS:Number = 18.15;
		public static const PEA_MASS:Number = 8.05;
		public static const PEA_ROTATION_DRAG:Number = 6; //higher means the pea will stop rolling faster
		public static const PEA_SPLIT_SCORE:Number = 1500;
		public static var modifiedPeaRadius:Number = PEA_RADIUS;
		public static const FAST_FORWARD_SPEED:Number = 3.5;		
		public static const LEVEL_KEY:String = "I Love Kim";
		public static const LEVEL_SCALES:Object = { xsmall:1.555,
													small:1, //9x9
													medium:.8, //11x11
													large:.67, //13x12
													xlarge:.41}
		
		//PEA stops when it reaches the minimum angular and linear velocities
		public static const MINIMUM_ANGULAR_VELOCITY:Number = 1.2
		public static const MINIMUM_VELOCITY:Number = 1.2;
		
		//PEA dies if the Y velocity is greater than the death velocity when it hits
		public static const PEA_DEATH_VELOCITY:Number = 9.5;
		
		//the number of times a pea can hit a block during one jump before it is considered a trap
		public static const PEA_TRAPPED_HITS:Number = 10;
		public static const HAPPY_POINTS_PER_BLOCK:Number = 0x64;
		public static const MINIMUM_NINJA_JUMP_SCORE:Number = 0x320;
		public static const MAX_SCORED_JUMPS_PER_BLOCK:Number = 3;
		
		// values greater than one increase bounciness
		public static const SPRING_BOUNCINESS:Number = 1.17; 
		
		public static const SCREEN_LEFT_EDGE:Number = 0;
		public static const SCREEN_RIGHT_EDGE:Number = 650;
		public static const PLAY_AREA_HEIGHT:Number = 400;
		public static const PLAY_AREA_WIDTH:Number = 600;
		public static const GAME_WIDTH:Number = 700;
		public static const GAME_HEIGHT:Number = 500;
		
		public static const ADD_BLOCK_DELAY:Number = 1;
		
		//scores
		public static const SCORE_JUMP_UP_TO_BLOCK:Number = 100;
		public static const SCORE_JUMP_GAP:Number = 100;
		
		public static const GAME_VIEW_OFFSET_X:Number = 40;
		public static const GAME_VIEW_OFFSET_Y:Number = 441;
		public static var modifiedGameViewOffsetY:Number = GAME_VIEW_OFFSET_Y;
		
		public static const LEFT:Number = -1;
		public static const RIGHT:Number = 1;
		
		
		//BLOCKS
		public static const BLOCK_HEIGHT:Number = 50;
		public static const BLOCK_WIDTH:Number = 71;
		public static const FLAGPOLE_HEIGHT:Number = 68;
		public static const FLAG_HEIGHT:Number = 30;
		public static var modifiedBlockHeight:Number = BLOCK_HEIGHT;
		public static var modifiedBlockWidth:Number = BLOCK_WIDTH;
		
		public static const blocks:Object =
		{	standard:new Block("Standard", "standardBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsBox(width/2/worldScale, height/2/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			
			var worldBody:b2Body = world.CreateBody(newBody);
			if (worldBody != null)
				worldBody.CreateFixture(newFixture);
			
			
			return worldBody;
			} ),
			
			exit:new Block("Exit", "exitBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsBox(width/2/worldScale, height/2/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
			},  1, .6, false ),
				spring:new Block("Spring", "springBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsBox(width/2/worldScale, height/2/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			newFixture.restitution = Settings.SPRING_BOUNCINESS;
			var worldBody:b2Body = world.CreateBody(newBody);
			if (worldBody == null)
				return null;
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		} ),
				gel:new Block("Gel", "gelBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsBox(width/2/worldScale, height/2/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			var worldBody:b2Body = world.CreateBody(newBody);
			
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		} , .4, .2 ),
				leftRamp:new Block("Left Ramp", "leftRampBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale-Settings.modifiedBlockWidth/2/worldScale, location.y/worldScale+Settings.modifiedBlockHeight/2/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsArray([new b2Vec2(0.0, 0.0), new b2Vec2(Settings.modifiedBlockWidth/worldScale, -Settings.modifiedBlockHeight/worldScale),
			new b2Vec2(Settings.modifiedBlockWidth/worldScale, 0),
					]);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		} ),
				rightRamp:new Block("Right Ramp", "rightRampBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale-Settings.modifiedBlockWidth/2/worldScale, location.y/worldScale+Settings.modifiedBlockHeight/2/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsArray([new b2Vec2(0.0, 0.0), new b2Vec2(0, -Settings.modifiedBlockHeight/worldScale),
			new b2Vec2(Settings.modifiedBlockWidth/worldScale, 0),
					]);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		} ),
		topLeftRamp:new Block("Top Left Ramp", "topLeftRampBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale-Settings.modifiedBlockWidth/2/worldScale, location.y/worldScale+Settings.modifiedBlockHeight/2/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsArray([new b2Vec2(0.0, -Settings.modifiedBlockHeight/worldScale), new b2Vec2(Settings.modifiedBlockWidth/worldScale, -Settings.modifiedBlockHeight/worldScale),
			new b2Vec2(Settings.modifiedBlockWidth/worldScale, 0),
					]);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		} ),
		topRightRamp:new Block("Top Right Ramp", "topRightRampBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale-Settings.modifiedBlockWidth/2/worldScale, location.y/worldScale+Settings.modifiedBlockHeight/2/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsArray([new b2Vec2(0.0, 0.0), new b2Vec2(0, -Settings.modifiedBlockHeight/worldScale),
			new b2Vec2(Settings.modifiedBlockWidth/worldScale, -Settings.modifiedBlockHeight/worldScale),
					]);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		} ),
		spikey:new Block("Spikey", "spikeyBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsBox(width/2/worldScale, height/2/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
			}, 1, .6, false),
		slimey:new Block("Slimey", "slimeyBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(location.x/worldScale, location.y/worldScale);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsBox(width/2/worldScale, height/2/worldScale);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
		} ), 
		entranceBlock:new Block("Entrance", "entranceBlock", function (world:b2World, worldScale:Number, location:Point,width:Number,height:Number):b2Body {
			var newBody:b2BodyDef = new b2BodyDef();
			
			newBody.position.Set(-1000, 0);
			var newBox:b2PolygonShape = new b2PolygonShape();
			newBox.SetAsBox(0, 0);
			var newFixture:b2FixtureDef = new b2FixtureDef();
			newFixture.shape = newBox;
			
			var worldBody:b2Body=world.CreateBody(newBody);
			worldBody.CreateFixture(newFixture);
			
			return worldBody;
			}  )
			
			}
		
		//LEVELS
		public static const levels:Array = 
			[
			new Level("The Dream", ["standard"], [], new Point(0, 0), new Point(7, 0),
					new MochiDigits(0), new MochiDigits(1), "default", LEVEL_SCALES.small, [],
					new MochiDigits(0), new MochiDigits(200), new MochiDigits(600),[1,2]),
			new Level("Get Off the Ground", ["standard"], [], new Point(0, 0), new Point(7, 5), 
					new MochiDigits(200), new MochiDigits(1), "default", LEVEL_SCALES.small, [], 
					new MochiDigits(200), new MochiDigits(600), new MochiDigits(1200), [3]),
			new Level("The Fall", ["standard", "gel"], 
					[ { block:"standard", x:0, y:10 }, { block:"standard", x:1, y:10 }, { block:"standard", x:1, y:9 },
						{ block:"standard", x:1, y:8 },{ block:"standard", x:1, y:7}, { block:"standard", x:1, y:6}, { block:"standard", x:1, y:5}], new Point(0, 9),
					new Point(8, 5), new MochiDigits(700), new MochiDigits(1), "default", LEVEL_SCALES.medium, [ { type:"coin", x:9,  y:4 } ],
					new MochiDigits(600), new MochiDigits(1000), new MochiDigits(1200), [5]),
			new Level("Ouch! Spikes Hurt!", ["standard", "gel"], 
					[{block:"spikey", x:5, y:0},{block:"spikey", x:6, y:0},{block:"spikey", x:7, y:0},{block:"spikey", x:10, y:0}], 
					new Point(0, 0), new Point(8, 0),
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.medium, [],
					new MochiDigits(800), new MochiDigits(1300), new MochiDigits(1600), [4]),
		
			new Level("The Wall", ["standard", "gel", "spring"], 
					[ { block:"slimey", x:5, y:0 }, { block:"slimey", x:5, y:1 }, { block:"slimey", x:5, y:2 }, 
						{block:"slimey", x:5, y:3}, {block:"slimey", x:5, y:4}, {block:"slimey", x:5, y:5}], 
					new Point(0, 0), new Point(9, 5),
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.medium, [ { type:"coin", x:6,  y:1 } ], 
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600), [6]),
			new Level("Roll It In", ["standard", "gel", "spring", "leftRamp", "rightRamp"], 
					[{block:"standard", x:7, y:1}, {block:"standard", x:8, y:2}, {block:"standard", x:9, y:3}, {block:"standard", x:10, y:4}   ], 
					new Point(0, 0), new Point(10, 0), 
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.medium, [ { type:"coin", x:9,  y:4 } ],
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600)),
			new Level("Jump The Gap or Not", ["standard", "gel", "spring", "leftRamp", "rightRamp"], 
					[ { block:"spikey", x:5, y:3 }, { block:"standard", x:5, y:0 }, { block:"standard", x:5, y:1 },
						{block:"standard", x:5, y:2 }, { block:"standard", x:5, y:6 }, { block:"standard", x:5, y:7 },
						{block:"standard", x:5, y:8 }, { block:"standard", x:5, y:10 },
						{block:"standard", x:4, y:10 }, { block:"standard", x:3, y:10 }, { block:"standard", x:2, y:10 },
						{block:"standard", x:1, y:10},{block:"standard", x:0, y:10}], 
					new Point(0, 0), new Point(8, 0),
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.medium, [ { type:"coin", x:5,  y:5 } ],
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600)),							
			new Level("Maze", ["standard", "gel", "spring", "leftRamp", "rightRamp"], 
					[ { block:"standard", x:0, y:10 }, { block:"standard", x:1, y:10 }, { block:"standard", x:2, y:10 },
						{block:"standard", x:3, y:10 }, { block:"standard", x:4, y:10 }, { block:"standard", x:7, y:10 },
						{block:"standard", x:8, y:10 }, { block:"standard", x:9, y:10 }, { block:"standard", x:10, y:10 },
						{block:"standard", x:11, y:10 },
						{ block:"standard", x:0, y:7 }, { block:"standard", x:1, y:7 }, { block:"standard", x:4, y:7 },
						{block:"standard", x:5, y:7 }, { block:"standard", x:6, y:7 }, { block:"standard", x:7, y:7 },
						{block:"standard", x:8, y:7 }, { block:"standard", x:9, y:7 }, { block:"standard", x:10, y:7 },
						{block:"standard", x:11, y:4 },
						{ block:"standard", x:0, y:4 }, { block:"standard", x:1, y:4 }, { block:"standard", x:2, y:4 },
						{block:"standard", x:3, y:4 }, { block:"standard", x:4, y:4 }, { block:"standard", x:5, y:4 },
						{block:"standard", x:6, y:4 }, { block:"standard", x:9, y:4 }, { block:"standard", x:10, y:4 },
						{ block:"standard", x:10, y:3 },{ block:"standard", x:10, y:2 },{ block:"standard", x:10, y:1 }, { block:"standard", x:10, y:0 }
						], 
					new Point(0, 11), new Point(0, 0),
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.large, [ { type:"coin", x:2,  y:8 } ],
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600)),					
			new Level("Cliffhanger", ["standard", "gel", "spring", "leftRamp", "rightRamp"], 
					[ { block:"standard", x:3, y:0 }, { block:"standard", x:3, y:1 }, { block:"standard", x:3, y:2 },
						{block:"standard", x:3, y:3 }, { block:"standard", x:3, y:4 }, { block:"standard", x:2, y:4 },
						{block:"standard", x:10, y:11 }, { block:"standard", x:9, y:11 }, { block:"standard", x:9, y:10 },
						{block:"standard", x:9, y:9 }, { block:"standard", x:9, y:8 }, { block:"standard", x:9, y:7 },
						{block:"standard", x:9, y:6},{block:"spikey", x:11, y:6}], 
					new Point(0, 0), new Point(11, 8),
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.large, [ { type:"coin", x:9,  y:4 } ], 
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600)),
			new Level("Santa Claus", ["standard", "gel", "spring", "leftRamp", "rightRamp", "topLeftRamp", "topRightRamp"], 
					[ { block:"standard", x:3, y:0 }, { block:"standard", x:3, y:1 }, { block:"standard", x:3, y:2 },
						{block:"standard", x:3, y:3 }, { block:"standard", x:3, y:4 }, { block:"leftRamp", x:3, y:5 },
						{block:"leftRamp", x:4, y:6 }, { block:"leftRamp", x:5, y:7 }, { block:"leftRamp", x:6, y:8 },
						{block:"rightRamp", x:7, y:8 }, { block:"standard", x:8, y:6 }, { block:"standard", x:8, y:7 }, 
						{block:"standard", x:8, y:8 }, { block:"standard", x:10, y:6 }, { block:"standard", x:10, y:0 },
						{block:"standard", x:10, y:1 }, { block:"standard", x:10, y:2 }, { block:"standard", x:10, y:3 },
						{block:"standard", x:10, y:4 }, { block:"standard", x:10, y:5 }, { block:"standard", x:10, y:7 },
						{block:"standard", x:10, y:8}], 
					new Point(0, 0), new Point(5, 0), 
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.large, [ { type:"coin", x:11,  y:10 },
					{type:"coin", x:0,  y:10 } ],
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600)),
			new Level("Jump The Gap Again or Not", ["standard", "gel", "spring", "leftRamp", "rightRamp", "topLeftRamp", "topRightRamp"], 
					[ { block:"spikey", x:5, y:3 }, { block:"standard", x:5, y:0 }, { block:"standard", x:5, y:1 },
						{block:"standard", x:5, y:2 }, { block:"standard", x:5, y:6 }, { block:"standard", x:5, y:7 },
						{block:"standard", x:5, y:8 }, { block:"standard", x:5, y:9 }, { block:"standard", x:5, y:10 },
						{block:"standard", x:4, y:10 }, { block:"standard", x:3, y:10 }, { block:"standard", x:2, y:10 },
						 { block:"standard", x:0, y:10 }, { block:"spikey", x:8, y:2 },
						{block:"standard", x:8, y:0 }, { block:"standard", x:8, y:1 }, 
						{block:"standard", x:7, y:6 }, { block:"standard", x:7, y:7 }, { block:"standard", x:7, y:8 },
						{block:"standard", x:7, y:9},{block:"standard", x:7, y:10},{block:"standard", x:6, y:10}], 
					new Point(0, 0), new Point(10, 0), 
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.large, [ { type:"coin", x:5, y:5},{ type:"coin", x:6, y:5}, { type:"coin", x:6, y:4},  { type:"coin", x:6, y:3} ], 
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600)),			
				new Level("Free Play", ["standard", "gel", "spring", "leftRamp", "rightRamp", "topLeftRamp", "topRightRamp"], [], new Point(0, 0), new Point(0, 10),
					new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.large, [],
					new MochiDigits(1000), new MochiDigits(1300), new MochiDigits(1600)),
			]		
			
			public static const levelScoreboards:Array = 
			[
				function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [10, 2, 15, 15, 3, 14, 1, 3, 0, 9, 4, 11, 1, 11, 14, 5], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};										
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard( { boardID: boardID, score: value.value, onClose:onClose  } );
						},
				function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [5, 5, 11, 7, 2, 5, 3, 14, 10, 13, 1, 9, 14, 2, 8, 8], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [13, 13, 0, 0, 4, 13, 13, 3, 4, 5, 3, 2, 8, 3, 2, 3], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [15, 14, 1, 4, 11, 10, 14, 4, 5, 5, 9, 8, 11, 1, 1, 12], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [13, 5, 3, 0, 1, 5, 12, 2, 12, 14, 11, 5, 10, 10, 8, 6], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [0, 11, 3, 7, 5, 13, 1, 6, 4, 8, 12, 1, 2, 6, 9, 12], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [15, 2, 12, 11, 6, 11, 5, 13, 5, 14, 5, 3, 1, 9, 11, 6], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [3, 12, 5, 10, 13, 5, 9, 1, 4, 9, 13, 2, 0, 2, 0, 10], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [14, 7, 8, 4, 6, 13, 10, 9, 10, 12, 5, 12, 6, 0, 12, 13], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [7, 8, 15, 10, 11, 9, 6, 4, 9, 10, 3, 12, 4, 10, 7, 9], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [14, 14, 14, 15, 12, 3, 3, 1, 10, 14, 6, 12, 8, 9, 13, 4], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
					function(value:MochiDigits, onClose:Function):void {				
							var o:Object = { n: [2, 10, 1, 8, 11, 9, 4, 2, 0, 15, 14, 1, 1, 13, 5, 10], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
							var boardID:String = o.f(0,"");
							MochiScores.showLeaderboard({boardID: boardID, score: value.value, onClose:onClose  });
						},
			]
	}	
}

/*
* 
 * 
			new Level("I. The Dream", ["standard"], [], new Point(0, 0), new Point(7, 0), new MochiDigits(200), new MochiDigits(1), "default", LEVEL_SCALES.small, [], new MochiDigits(400), new MochiDigits(800), new MochiDigits(1600)),
			new Level("II. The Reality", ["standard", "rightRamp", "leftRamp"], 
					[{block:"spikey", x:5, y:0},{block:"spikey", x:6, y:0},{block:"spikey", x:7, y:0},{block:"spikey", x:10, y:0}], 
							new Point(0, 0), new Point(8, 0), new MochiDigits(400), new MochiDigits(1), "default", LEVEL_SCALES.medium,[], new MochiDigits(400), new MochiDigits(800), new MochiDigits(1600)),
					new Level("III. The Fall", ["standard", "rightRamp", "leftRamp","gel"], [], new Point(0, 10), new Point(8, 5), new MochiDigits(800), new MochiDigits(1), "default", LEVEL_SCALES.medium,[], new MochiDigits(400), new MochiDigits(800), new MochiDigits(1600)),
					new Level("IV. The Wall", ["standard", "gel", "spring"], 
							[{block:"slimey", x:5, y:0},{block:"slimey", x:5, y:1}, {block:"slimey", x:5, y:2}, {block:"slimey", x:5, y:3}, {block:"slimey", x:5, y:4}, {block:"slimey", x:5, y:5}], 
							new Point(0, 0), new Point(9, 5), new MochiDigits(1000), new MochiDigits(1), "default", LEVEL_SCALES.medium,[], new MochiDigits(400), new MochiDigits(800), new MochiDigits(1600)),
					new Level("V. The Ramp", ["standard", "rightRamp", "leftRamp","gel", "spring"], [], new Point(0, 10), new Point(9, 9), new MochiDigits(1600), new MochiDigits(1), "default", LEVEL_SCALES.medium,[], new MochiDigits(400), new MochiDigits(800), new MochiDigits(1600))
*/