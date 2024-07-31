( // frequency tracking
var qitchBuffer = Buffer.read(Server.default,"/Users/marinos/Library/Application Support/SuperCollider/Extensions/SC3plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR44100.wav"); // path to auxiliary wav file for Qitch
{   // a complex signal
	var sound = Saw.ar(LFNoise2.ar(1).range(500,1000).poll(label:\ActualFrequency)) + WhiteNoise.ar(0.4);
	ZeroCrossing.ar(sound).poll(label:\ZeroCross);
	Pitch.kr(sound).poll(label:\Pitch);
	Tartini.kr(sound).poll(label:\Tartini);
	Qitch.kr(sound,qitchBuffer).poll(label:\Qitch);
	Out.ar(0,sound!2);
}.play;
)
