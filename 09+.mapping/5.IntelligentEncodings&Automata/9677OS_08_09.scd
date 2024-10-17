( // A game of life implentation
Server.default.waitForBoot({
	var synth; // synth to be used later

	var cells = Array.fill(32,{Array.fill(16,{[1,0].wchoose([0.3,0.7])})}); // an 32x16 grid

	var updateCell = {arg xIndex,yIndex; // function to count neighbours and update cells' state
		var neighbours = 0 ; // initial number of neighbours
		var state = cells[xIndex][yIndex]; // set current state
		var newState = state; // new state
		// first count neighbours
		[-1,0,1].do{arg i; 
			[-1,0,1].do{arg j; 
				neighbours = neighbours +
				cells.foldAt(xIndex+i).foldAt(yIndex+j);
			}
		};
		
		if (state.asBoolean) {neighbours = neighbours - 1}; // if state is not 0, subtract cell's own state 
		case  // calculate new state
		{state.asBoolean && (neighbours < 2)} {newState = 0} // it dies from loneliness.
		{state.asBoolean && (neighbours > 3)} {newState = 0} // it dies from overpopulation.
		{state.asBoolean.not && (neighbours == 3)} {newState = 1}; // birth
		// update
		cells[xIndex][yIndex] = newState;
	};
	
	var window = Window("Game of life", 640@320).front.onClose_({synth.free}); 
	var userView = UserView(window, 640@320).background_(Color.magenta).animate_(true).frameRate_(40).drawFunc_({ // setup UserView and callback func
		var speed = userView.frame % 4;
		synth.set(\array, cells.flatten); // sonify
		cells.do{arg xItem, xIndex;  // for each cell
			xItem.do{arg yItem, yIndex;
				if (yItem!=0) { // draw current state
					Pen.fillColor_(Color.new255(214,176,49));
					Pen.addRect(Rect(xIndex*20,yIndex*20,20,20));
					Pen.fill;
				}; 
				if (speed==0) {updateCell.(xIndex,yIndex);}; // calculate and draw new state
			};
		};
	});

	fork {  
		SynthDef(\gameOfLife, {
			var signal, array, magnitudes, phases;
			array = Control.names([\array]).kr(Array.fill(512,{0})).clump(2).flop; // Control is used to allow an array to be passed as an argument
			magnitudes = array[0]; // read argument magnitudes
			phases = array[1]; // read argument phases
			signal = Silent.ar(); // a silent signal since we will replace it
			signal = FFT(LocalBuf(512),signal); // FFT
			signal = signal.pvcalc(512,{
				[magnitudes,phases]; // manually set magnitudes and phases
			});
			signal = IFFT(signal); // inverse FFT
			Out.ar(0,signal!2);
		}).add; // add SynthDef
		Server.default.sync; // sync with Server
		synth = Synth(\gameOfLife); // start synth
	};
});
)

