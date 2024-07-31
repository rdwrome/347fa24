( // a spiral fractal factory 
~spiralFractalFactory = { arg numLevels, numBranches, points, colors = [Color.red, Color.green]; 
	
	var fChildren, fractal;
	var fractalFunc = thisFunction;    // assign thisFunction to a variable

	// generate children fractals
	if (numLevels > 0) { // if there are more levels to go
		var childrenPoints, childrenRadius; 
		// calculate the children positions for each for the branches
		childrenPoints = points!numBranches; // points are the same

		// for each level generate all branches and add them to fChildren array
		numBranches.do{ arg i; 
			fChildren = fChildren.add(fractalFunc.(numLevels-1, numBranches, childrenPoints[i],colors));
		};		
	} { // else set children to nil
		fChildren = nil;
	};
	
	// create fractal object
	fractal = (
		children: fChildren,   // an array with the children (all of them fractal objects, too), or nil
		branches: numBranches,   // how many branches
		originalPoints: points,
		counter: 0,
		animatePoints: nil, // to be updated by animate
		colors: colors,
		animate: { arg self, speed = 0.01, centerPoint;
			var localCounter; 
			self.counter = self.counter + speed; // increment counter
			localCounter = self.counter.fold2(1).abs;

			// set animate points
			self.animatePoints = Array.fill(self.branches, { arg i; 
				self.originalPoints * (localCounter.sin);
			});
			
			Pen.scale(0.99,0.99); // scale the whole fractal 
			
			self.branches.do{arg i; // for eaxh branch
				Pen.moveTo(self.animatePoints[i][0]); // start at first point
				Pen.scale(0.99,0.99); // scale subsequent segments
				Pen.rotate(i/2pi, centerPoint.x,centerPoint.y); // rotate subsequent segments
				Pen.strokeColor_(colors[0].blend(colors[1],localCounter)); // gradually move to target color 
				
				// create segments to all subsequent points
				self.animatePoints[i].do { arg point;
					Pen.lineTo(point); 
				};
				
				Pen.stroke; // draw strokes only
			};

			// animate children
			if (self.children.notNil) { // if there are children
				// draw all of their branches
				self.children.do{arg item; 
					item.animate(speed,centerPoint);
				};
			};
		};
	);
	
	fractal; // explicitely return fractal
};
)
