( // a particle/granular visualizer/sonifier
Server.default.waitForBoot({
	var data, dataMax, dataMin; // dataset, data-minimum and data-maximum values
	var window, userView; // parent window and userView
	var engine; // particle system and granular synthesis engine
	var index = 0; // a global index

	fork{
		// retrieve data
		data = CSVFileReader.read("arrhythmia.data".absolutePath,true,true);

		// preprocess data
		data = data.flatten.collect(_.asInteger); // convert to mono-dimensional array of Integers
		data = data.select(_!=0); // remove zeros
		data = data.collect(_.abs); // make all positive
		dataMax = data.max; // store maximum value
		dataMin = data.min; // store minimum value
		data = data.reshape((data.size/4).asInteger,4); // convert to a 2D Array containing 4-entried datasets - first shall be raius the rest 3 color

		// encode data
		data = data.collect{arg item;
			var radius, color, freq, duration;
			radius = item[0].curvelin(dataMin,dataMax,0,40,-6); // encode radiuses to be 0-60
			color = Color.new255(
				red:item[1].explin(dataMin,dataMax,0,255),
				green:item[2].explin(dataMin,dataMax,0,255),
				blue:item[3].explin(dataMin,dataMax,0,255)
			);
			freq = [
				item[1].expexp(dataMin,dataMax,200,4000),
				item[2].expexp(dataMin,dataMax,200,4000),
				item[3].expexp(dataMin,dataMax,200,4000),
			];
			duration = item[0].explin(dataMin,dataMax,0,0.2);
			[radius, color, freq, duration];
		}; // at this point every element of data is a [radius, color, freq, duration] array

		//SynthDef
		SynthDef(\grain, { arg freqA, freqB, freqC, duration;
			var sound;
			sound = [ SinOsc.ar(freqA),SinOsc.ar(freqB)];
			sound = sound + Pan2.ar(SinOsc.ar(freqC),0);
			sound = sound * EnvGen.ar(Env.sine(duration),doneAction:2);
			sound = sound * duration * 0.2;
			Out.ar(0,sound)
		}).add; // add synthDef
		Server.default.sync; // sync with the Server

		// a particle/granular engine
		engine = { arg width, height, distance, dataset, index;
			(width/distance).floor.do{arg ix; // loop over the horizontal axis
				(height/distance).floor.do{arg iy; // loop over the vertical axis
					var x,y;
					var color, radius, xoffset, yoffset;
					color = dataset.wrapAt(index+ix+iy)[1]; // wrapAt so that it loops
					radius = dataset.wrapAt(index+ix+iy)[0]; // wrapAt so that it loops
					x = (distance/2) + (ix * distance); // calculate coordinates
					y = (distance/2) + (iy * distance); // calculate coordinates
					Pen.fillColor_(color); // set color
					Pen.addArc(x@y,radius,0,2pi); // draw a circle
					Pen.fill; // fill it
					Synth(\grain,[ // generate a grain per particle
						\freqA, dataset.wrapAt(index+ix+iy)[2][0],
						\freqB, dataset.wrapAt(index+ix+iy)[2][1],
						\freqC, dataset.wrapAt(index+ix+iy)[2][2],
						\duration, dataset.wrapAt(index+ix+iy)[3]
					]);
				};
			};
		};

		{	// make GUI
			window = Window("data-generated particles and grains", 640@640).front;
			userView = UserView(window, 640@640).background_(Color.white).animate_(true).frameRate_(30).clearOnRefresh_(false).drawFunc_({
				if (( userView.frame % 2) == 0) {index = index + 1}; // increment index every two frames

				// add trails
				Pen.fillColor_(Color(1,1,1,0.7)); // a transparent white
				Pen.addRect(Rect(0,0,640,640));   // create a semi-transparent rectangle to cover previous contents
				Pen.fill; // draw rectangle

				// run engine
				engine.(640,640,70, data, index);
			});
		}.defer;
	}
})
)
