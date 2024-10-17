( // Trailing waveforms
Server.default = Server.internal; // make internal the default server
Server.default.waitForBoot({ // boot server
	var window; // parent window
	var scopes; // and array of 8 scopeViews
	var buffers; // the output buffers to update the ScopeViews

	buffers= Array.fill(8,{Buffer.alloc(Server.default,1024,2)}); // allocate the buffers
	
	// make GUI 
	window = Window("Trailing waveforms.", 640@480,false).front; 
	window.onClose_({Ndef.clear; buffers.do{arg i; i.free;}});
	scopes = Array.fill(8,{arg i; ScopeView(window,Rect(0,0,640,480))
		.bufnum_(buffers[i].bufnum) 
		.backColor_(Color(0.6,0.8,0.9,1/4))
		.waveColors_([Color.green,Color.yellow]);
	});
	
	// modulate horizontal zoom factor on all views with respect to their index
	fork{loop{
		scopes.do{arg item,index; 
			{item.xZoom_( 4 + (3*(sin((Main.elapsedTime / 2) + (index*0.02)))));}.defer;
		};
		0.1.wait; // change factor every 0.1 seconds
	}};
	
	// a stereo sound example
	Ndef(\sound, {[Demand.ar(Impulse.ar(4000), 0,
		Dfsm([[0], // start at step 0
			Dbrown(-1,1,0.1,4),[0,1],  // step 0: generate 4 random values (brownian distribution) and then go to step 0 or step 1
			-1,[0,1,2],               // step 1: generate -1 and go to step 0 or to step 1 or to step 2
			Dseq([-0.2,-0.4,-0.8],6),[0,3],  // step 2: generate 6 sequences of -0.2,-0.4,-0.8 and then go to either step 0 or to step 3
			Dwhite(-0.5,1,10),[2]    // step: 3 generate 10 random values in the -0.5,1 range then go to step 2
		]));,(LeakDC.ar( SinOsc.ar(mul:4,add:2) << WhiteNoise.ar(2,2)) >> 3) * 0.2]*0.8}).play;  

	// write audio to the ScopeViews' buffers
	Ndef(\a1, {ScopeOut.ar(Ndef(\sound).ar,buffers[0])}).play;
	Ndef(\a2, {ScopeOut.ar(Ndef(\sound).ar,buffers[1])}).play;
	Ndef(\a3, {ScopeOut.ar(Ndef(\sound).ar,buffers[2])}).play;
	Ndef(\a4, {ScopeOut.ar(Ndef(\sound).ar,buffers[3])}).play;
	Ndef(\a5, {ScopeOut.ar(Ndef(\sound).ar,buffers[4])}).play;
	Ndef(\a6, {ScopeOut.ar(Ndef(\sound).ar,buffers[5])}).play;
	Ndef(\a7, {ScopeOut.ar(Ndef(\sound).ar,buffers[6])}).play;
	Ndef(\a8, {ScopeOut.ar(Ndef(\sound).ar,buffers[7])}).play;
});
)