( // bouncing balls example
var window, userView, ball; // window, userView and ball
var wind, gravity, frictionX, frictionY; // various forces

// first load the ball factory
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_05_10.scd").loadPaths;

window = Window("bouncing ball", 640@640).front;
userView = UserView(window, 640@640).background_(Color.black).animate_(true).frameRate_(60).drawFunc_({
	if ((userView.frame % 240) == 0) { // every 4 seconds (4 x 60frames)

		// create a ball of random characteristics
		var mass = rrand(5,15);
		var flex = rrand(0.7,1.0).trunc(0.1);
		ball = ~ballFactory.(radius:40,
			initialPosition:Point(rrand(0,400),0),
			color:Color.rand, mass:mass, flex:flex,
			bounds: 640@640);
		("New ball of mass" + mass + "and of flex" + flex + "created").postln;
		// create random forces
		wind = RealVector3D[rrand(0.01,0.3).trunc(0.01),rrand(0.01,0.3).trunc(0.01),rrand(0,0.3).trunc(0.01)]; // wind from some random direction
		gravity = RealVector3D[0,0.4,0]; // gravity is always 0.8
		frictionX = RealVector3D[0.1,0,0]; // horizontal friction
		frictionY = RealVector3D[0,0.1,0]; // vertical friction
		("Forces applied are: Wind," + wind + "Gravity," + gravity + "Horizontal Friction," + frictionX + "Verical Friction" + frictionY).postln;
	};

	// add forces to the ball
	ball.addForce(wind);
	ball.addForce(gravity);
	if ((ball.position.x > 640) || (ball.position.x < 1)) {
		// if touching horizontal edges apply horizontal friction
		ball.addForce(frictionX);
	} { // else if touching the bootom apply vertical friction
		if (ball.position.y == 640);
		ball.addForce(frictionY);
	};

	ball.draw(); // draw the ball
});
)
