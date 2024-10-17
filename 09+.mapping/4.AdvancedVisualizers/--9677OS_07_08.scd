( // data-drive spiral fractal

(PathName(thisProcess.nowExecutingPath).pathOnly ++ "/9677OS_07_07.scd").loadPaths; // first load the spiralFractalFactory

Server.default.waitForBoot({ fork{ // boot server and start routine
	
	var window, userView, fractal, sound, loop;

	SynthDef(\gliss,{ arg freqA = 100, freqB=200, dur=15; 
		var sound = LFSaw.ar(Line.kr(freqA,freqB,dur,doneAction:2));
		Out.ar(0,sound!2);
	}).add; // add SynthDef
	Server.default.sync; // sync with Server
	
	// retrieve and encode data
	loop = fork{loop{ { // defer
		var data, points, colors;
		
		// retrieve points 
		"curl \"http://www.random.org/integers/?num=10&min=1&max=640&col=1&base=10&format=plain&rnd=new\"  > data.temp".unixCmd({ // this function is called when the process has exited
			data = FileReader.read("data.temp", delimiter: '\n');
			data = data.collect(_.asInteger); // convert to Integer
			data = data.reshape(6,2); // reshape as pairs
			points = data.collect(_.asPoint); // convert to Point
			File.delete("data.temp"); // delete temporary file

			// map points as frequencies for our Synths
			points.do{ arg point;
				var freqA, freqB;
				freqA = point.x.linlin(0,640,100,1000); // linear mapping
				freqB = point.y.linlin(0,640,100,1000); // linear mapping
				sound.free; // first stop previous synth
				sound = Synth(\gliss,[\freqA, freqA,\freqB, freqB, \dur, 15]);
			};
			
			// retrieve colors
			"curl \"http://www.random.org/integers/?num=6&min=1&max=255&col=1&base=10&format=plain&rnd=new\"  > data.temp".unixCmd({ // this function is called when the process has exited
				data = FileReader.read("data.temp", delimiter: '\n');
				data = data.collect(_.asInteger); // convert to Integer
				data = data.reshape(2,3);  // reshape as triples
				colors = [
					Color.new255(data[0][0],data[0][1],data[0][2]), 
					Color.new255(data[1][0],data[1][1],data[1][2]), 
				];
				File.delete("data.temp"); // delete temporary file
			});
		
			// create a new fractal
			fractal = ~spiralFractalFactory.value(4,3,points,colors);
		});		
	}.defer;
		15.wait; // repeat process every 15 seconds
	}};

 	1.wait; // wait a second 
	
	{ // defer
		window = Window.new("Data-driven spiral fractal", 640@640).front.onClose_({loop.stop; sound.free;});
		userView = UserView(window, 640@640).background_(Color.black).animate_(true).frameRate_(40).clearOnRefresh_(false).drawFunc_({
			// add trails
			Pen.fillColor_(Color(0,0,0,0.4)); 
			Pen.addRect(Rect(0,0,640,640));   
			Pen.fill; 
			// rotate fractal 
			Pen.rotate((userView.frame / 20 ).cos,320,320);
			// draw fractal
			fractal.animate(0.01,320@320);
		});
	}.defer;
}});
)
