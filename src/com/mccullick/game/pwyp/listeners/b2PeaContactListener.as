package com.mccullick.game.pwyp.listeners 
{
	import Box2D.Collision.b2ContactPoint;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	import caurina.transitions.Tweener;
	import com.mccullick.game.pwyp.Block;
	import com.mccullick.game.pwyp.GameModel;
	import com.mccullick.game.pwyp.GameStats;
	import com.mccullick.game.pwyp.Pea;
	import com.mccullick.game.pwyp.PlayWithYourPeas;
	import com.mccullick.game.pwyp.Settings;
	import com.reintroducing.sound.SoundManager;
	import flash.geom.Point;
	import com.mccullick.events.DataEvent;

	
	/**
	 * ...
	 * @author Philip McCullick
	 */
	public class b2PeaContactListener extends b2ContactListener 
	{
		
		/**
		 * Called when two fixtures begin to touch.
		 */
		public override function BeginContact(contact:b2Contact):void {
			var bodyA:b2Body = contact.GetFixtureA().GetBody();
			var peaBody:b2Body = contact.GetFixtureB().GetBody();
			var peaData:Object = peaBody.GetUserData();
			
			peaBody.SetAngularVelocity(peaBody.GetAngularVelocity() / (Settings.PEA_ROTATION_DRAG*1/GameStats.getInstance().currentLevel.scale));
			if (peaData.pea.gapJump)
			{
				peaBody.SetLinearVelocity(new b2Vec2(0, 0));
				peaBody.SetAngularVelocity(0);
				
			}else
			{
				var bHitBlockTop:Boolean = true; 
				
				var peaBlock:Point = GameModel.convertGameToBlockCoord(peaData.pea.x, peaData.pea.y+peaData.pea.height/3);
				//check if this is hitting the top of the block
				if (!bodyA.GetUserData().barrier)
				{
					var bIsRamp:Boolean = bodyA.GetUserData().block.blockId == "rightRampBlock" || 
											 bodyA.GetUserData().block.blockId == "leftRampBlock";
				trace(bodyA.GetUserData().block.blockY  + " >= " + peaBlock.y );
					if (!bIsRamp && bodyA.GetUserData().block.blockY >= peaBlock.y)
					{
						bHitBlockTop = false;
					}
					if (bHitBlockTop && peaData.pea.usingPhysics)
					{
						var onTopOfBlock:Block = bodyA.GetUserData().block;
						if (onTopOfBlock.title == Settings.blocks.exit.title)
						{
							peaData.pea.usingPhysics = false;
							peaData.pea.addBounceBlock(onTopOfBlock);
							peaData.model.endPhysicsPea(peaData.pea, peaBody);
							peaData.pea.startWaiting();
							peaData.pea.stage.dispatchEvent(new DataEvent(PlayWithYourPeas.LEVEL_COMPLETED_EVENT, { pea:peaData.pea  } ));
							peaData.pea.scoredJump = false;
							return;
						}else if (onTopOfBlock.title == Settings.blocks.spikey.title)
						{
							peaData.pea.scoredJump = false;
							peaData.model.killPea(peaData.pea);
							return;
						}
					}
				}
				trace("hit top: " + bHitBlockTop);
				
				trace(contact.GetFixtureB().GetBody().GetDefinition().linearVelocity.y > Settings.PEA_DEATH_VELOCITY -(.8 - GameStats.getInstance().currentLevel.scale) * 6 )
				trace(((bodyA.GetUserData().barrier &&  bodyA.GetUserData().type == "floor") || (bodyA.GetUserData().block.blockId != "gelBlock" && bodyA.GetUserData().block.blockId != "springBlock" && bHitBlockTop)));
				//if the velocity is too great and this isnt a safe block				
				trace("velocity: " + contact.GetFixtureB().GetBody().GetDefinition().linearVelocity.y);
				trace("death velocity:" + (Settings.PEA_DEATH_VELOCITY -(.8 - GameStats.getInstance().currentLevel.scale) * 5 ));
				if (contact.GetFixtureB().GetBody().GetDefinition().linearVelocity.y > Settings.PEA_DEATH_VELOCITY -(.8-GameStats.getInstance().currentLevel.scale)*5 &&
					((bodyA.GetUserData().barrier &&  bodyA.GetUserData().type=="floor") || (bodyA.GetUserData().block.blockId != "gelBlock" && bodyA.GetUserData().block.blockId != "springBlock" && bHitBlockTop)))
				{				
					peaData.model.killPea(peaData.pea);
					
					SoundManager.getInstance().playSound("fxWah", 1*Settings.SOUND_VOLUME, 0, 0, "fx");
				} else if (bodyA.GetUserData() != null&& bodyA.GetUserData().block != null)
				{
					var block:Block = bodyA.GetUserData().block;
					if ( block.blockId == "gelBlock")
					{	
						peaBody.SetLinearVelocity(new b2Vec2(0, 0));
						block.showWaterSplashAnimation();
					}
					var totalHits:Number = peaData.pea.addBounceBlock(block);
					if (totalHits == 1 && peaData.pea.scoredJump)
					{				
						
						Tweener.addTween(block, { _saturation:4,  time:.5, transition:"easeOutQuart", onComplete:function():void
							{
								Tweener.addTween(block, {  _saturation:1,  time:.5, transition:"easeOutQuart" } );
							}});

					}
					if (totalHits > Settings.PEA_TRAPPED_HITS)
					{
						peaData.model.trappedPea(peaData.pea);
					}
				}else if ( bodyA.GetUserData().barrier)
				{
					if (bodyA.GetUserData().type=="wall" && !peaData.pea.switchedDirectionsDuringJump)
					{
						peaData.pea.switchedDirectionsDuringJump = true;
						peaData.pea.switchDirections();
					}
				}
				
				peaData.pea.showPain();
				
				//trace(contact.GetFixtureB().GetBody().GetDefinition().linearVelocity.y);
				//trace("contact started: " + contact);
			}
			
		}

		/**
		 * Called when two fixtures cease to touch.
		 */
		public override function EndContact(contact:b2Contact):void { 
			//trace("contact ended: " + contact);
		}

		/**
		 * This is called after a contact is updated. This allows you to inspect a
		 * contact before it goes to the solver. If you are careful, you can modify the
		 * contact manifold (e.g. disable contact).
		 * A copy of the old manifold is provided so that you can detect changes.
		 * Note: this is called only for awake bodies.
		 * Note: this is called even when the number of contact points is zero.
		 * Note: this is not called for sensors.
		 * Note: if you set the number of contact points to zero, you will not
		 * get an EndContact callback. However, you may get a BeginContact callback
		 * the next step.
		 */
		public override function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void {}

		/**
		 * This lets you inspect a contact after the solver is finished. This is useful
		 * for inspecting impulses.
		 * Note: the contact manifold does not include time of impact impulses, which can be
		 * arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
		 * in a separate data structure.
		 * Note: this is only called for contacts that are touching, solid, and awake.
		 */
		public override function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void { 
		
		}
		
		
		
		

	}

}