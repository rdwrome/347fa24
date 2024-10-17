( // mouse interaction
var window, userView, windmill; // window, userView, windmill
var speed = 100;  // initial speed
var position = Point(225,225); // position
var trailsDensity = 0.1;  // trailling effect

// first load the windmill factory
(PathName(thisProcess.nowExecutingPath).pathOnly ++ "9677OS_05_windmill_factory.scd").loadPaths;

windmill = ~windmillFactory.(225@225,150); // create a windmill

// UserView and drawing funciton
window = Window("mouse interaction", 450@450).front;
userView = UserView(window, 450@450).background_(Color.white).animate_(true).frameRate_(60).clearOnRefresh_(false).drawFunc_({
	// add trailing effect
	Pen.fillColor_(Color(1,1,1,trailsDensity));
	Pen.addRect(Rect(0,0,450,450));
	Pen.fill;
	// add a rotating windmill
	Pen.push;
	Pen.rotate( tan(userView.frame / speed) * 2pi, x,y);
	windmill.draw();
	Pen.pop;
});

// event handlers
window.acceptsMouseOver_(true); // this has to be set to true for the handlers to function properly
userView.mouseDownAction_({arg view, x, y, modifiers,buttonNumber,clickCount;
	if (clickCount==1) { // on one click
		speed = rrand(10,200); // use this to change speed
	} { // on more clicks
		trailsDensity = rrand(0.1,0.6); // change trailing effect's density
	}
});
userView.mouseOverAction_({arg view, x, y; // on mouseOver
	position = x@y;  // use this to change the rotation's center
	windmill.refresh(x@y); 	// change windmill's positioning
});
)
