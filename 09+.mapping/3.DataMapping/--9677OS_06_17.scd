( // Beatracking example
var buffer = Buffer.read(Server.default, "/path/to/some/audio/file/with/prominent/rhythm"); // use an audio file with prominent rhythm here
{   var sound = PlayBuf.ar(1,buffer,BufRateScale.ir(buffer),loop:1)*4; // loop through the file
	var fft = FFT(LocalBuf(512),sound);
	var analysis = BeatTrack.kr(fft); // analyze it
	var tempo = analysis[3].poll(label:\EstimatedTempo); // print the estimated tempo
	var beat = Decay.kr(analysis[1],0.2) * WhiteNoise.ar(0.1); // clicks produced on the  right channel
	Out.ar(0,[sound,beat]);
}.play;
)
