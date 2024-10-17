( // 1-dimension cellular automata
Server.default.waitForBoot({
	var synth; // a synth used later
	var ruleSet = [60,90,102,150].choose.asBinaryDigits; // randomly choose a rule and convert to an Array of binary digits
	var cells = Array.fill(512,{[0,1].choose([0.95,0.05])}); // a random seed of mainly 0s and just a few 1s at random places 
	var generateAccordingToRule = { arg a,b,c; // simply map each neighborhood state to each digit of our rule, respectively  
		case 
		{(a == 0) && (b == 0) && (c == 0)} {ruleSet[0]}
		{(a == 0) && (b == 0) && (c == 1)} {ruleSet[1]}
		{(a == 0) && (b == 1) && (c == 0)} {ruleSet[2]}
		{(a == 0) && (b == 1) && (c == 1)} {ruleSet[3]}
		{(a == 1) && (b == 0) && (c == 0)} {ruleSet[4]}
		{(a == 1) && (b == 0) && (c == 1)} {ruleSet[5]}
		{(a == 1) && (b == 1) && (c == 0)} {ruleSet[6]}
		{(a == 1) && (b == 1) && (c == 1)} {ruleSet[7]};
	};
	var window = Window("1-dimension cellular automata", 512@200).front
	.onClose_({synth.free;}); // our parent window
	var userView = UserView(window, 512@200).background_(Color.magenta)
	.animate_(true).clearOnRefresh_(false).frameRate_(40).drawFunc_({ // setup UserView and callback func
		var counter = userView.frame % 200; 
		synth.set(\array, cells); // modulate synth
		512.do{ arg i; 
			// first draw each cell
			if (cells[i].asBoolean) {
				Pen.fillColor_(Color.yellow);
				Pen.addRect(Rect(i,counter,1,1));
				Pen.fill;
			};
			// then calculate next generation
			cells[i] = generateAccordingToRule.value(cells.foldAt(i-1),cells[i],cells.foldAt(i+1));
		};
		// when we have reaches the botom start from scratch with a new random rule and random seed
		if (counter == 0) {
			userView.clearDrawing; // clear previous contents
			ruleSet = [60,90,102,150].choose.asBinaryDigits; // randomly choose a rule and convert to an Array of binary digits

			cells = Array.fill(512,{0}); // an array of empty cells
			rrand(1,50).do{ // add a random number of 1s at random places to achieve a random seed
				cells[512.rand] = 1; 
			};
		};
	});	
	fork {  // sound 
		SynthDef(\caSynth, { // synthDef
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
		synth = Synth(\caSynth); // start synth
	};
});
)

