( // server-side testing & filtering
	{   var sound, fft, onset, freq, analysis;
		sound = Saw.ar(LFNoise2.kr(2).range(100,1000)); // a complex signal
		freq = Tartini.kr(sound); // frequency tracking
		sound = sound * EnvGen.kr(Env([0,1,0],[2,1],[\cubed,\step]).circle) * BrownNoise.ar(); // Ring modulate with BrownNoise and apply an envelope
		fft = FFT(LocalBuf(512),Mix.new(sound)); // fft for the onsets detector
		onset = Onsets.kr(fft,threshold:1); // detect onsets
		analysis = ( Decay.kr(onset) & ((Decay.kr(freq[1]) & (freq[0] > 800)) | ( Decay.kr(freq[1]) & (freq[0]<200)))); // 1 if there is an offset AND the detected frequency is being detected to be either above 800 or below 200 
		analysis.if(WhiteNoise.ar(),Silent.ar()) + (sound * 0.7); // mix signal with a noise pulse if the above is true
	}.play;
)

