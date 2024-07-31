(// a ball factory
~ballFactory = { arg radius=40, initialPosition=0@0, color=Color.green, mass=10, flex=0.9, bounds; // the bounds define when the ball should bounce 
	var ball = (
		velocity: RealVector3D[0,0,0],      // initial velocity
		mass: mass,   // the mass of the ball 
		flex: flex,  // 1 is perfectly non-elastic and 0 perfectly elastic
		position: initialPosition,  // position of the ball
		acceleration: RealVector3D[0,0,0],  // acceleration of the movement
		addForce: { arg self,force;   // add forces to the ball
			var normalizedForce;
			normalizedForce = force * self.mass; // force should be affected by the mass
			self.acceleration_(self.acceleration + normalizedForce); // calulcate acceleration
		},
		draw: {arg self;  // draw ball
			self.velocity_(self.velocity + self.acceleration); // calculate current velocity
			self.acceleration_(RealVector3D[0,0]); // reset acceleration
			self.position_(self.position + self.velocity); // calculate new position - we can indeed add a RealVector2D with a point !
			// make ball bounce
			if (self.position.y > bounds.y) { 
				self.velocity[1] = self.velocity[1].neg * self.flex;
				self.position.y = bounds.y; 
			};
			if (self.position.y < 1) { 
				self.velocity[1] = self.velocity[1].neg * self.flex;
				self.position.y = 1; 
			};
			if ((self.position.x > bounds.x) || (self.position.x < 1)) {
				self.velocity[0] = self.velocity[0].neg * self.flex;
			};
			Pen.fillColor_(color);
			Pen.addArc(self.position,radius,0,2pi);
			Pen.fill;
		}
	); 
	ball;
};
)
