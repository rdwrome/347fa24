( // simple decision-making encoder
Server.default.waitForBoot({ 
	var data = Array.fill(100,{rrand(0,1.0)}); // our dataset
	var mappingFunc = { arg datum; // the mapping function 
		if (datum<=0.5) { // if input is less than 0.5
			datum.linlin(0,0.5,200,400); // map linearly in the low register
		} {  // else map linearly to the high register
			datum.linlin(0.5,1.0,2000,4000);
		};
	};
	fork{loop{ // sonify dataset
		var freq;
		freq = mappingFunc.(data.choose);
		{SinOsc.ar(freq) * Line.ar(1,0,0.4,doneAction:2)}.play;
		0.5.wait;
	}};
})
)
