// analysis next week
// BOOT

//running water
(
x = {
	var trigs, freq;
	6.collect{
		trigs = Dust.kr(170);
		freq =
			// Generally choose from a varied base freq
			TExpRand.kr(800, 2000, trigs)
			// Wobbly variation
			+ LFNoise2.kr(20, mul: 300)
			// General tendency for upward rise
			+ EnvGen.kr(Env.perc(1).range(0,17), trigs)
			;
		SinOsc.ar(freq, 0, 0.3)
	}.mean
}.play;
)
x.free;

//electrical hum with sparks
(
{
var noise, phasor, chirpPulse, randGate, chirpAmp, clip, snap, trig, formant, comb;

phasor = LFSaw.ar([-99.8, 100.2], 1, 0.5, 0.5);

noise = WhiteNoise.ar!2;
noise[0] = OnePole.ar(noise[0], exp(-2pi * (0.1 * SampleDur.ir)));
noise[0] = OnePole.ar(noise[0], exp(-2pi * (0.1 * SampleDur.ir)));
noise[0] = noise[0].max(0) * 700 + 3;


// fig 39.4: Chirp pulse
chirpPulse = phasor[0].scope * noise[0];
chirpPulse = chirpPulse.min(1) - (chirpPulse.max(1) - 1 * 1e+09).min(1);
chirpPulse.scope;
chirpPulse = ((chirpPulse + 0.1)**2 * 12 * 2pi).cos * chirpPulse;
chirpPulse.scope;
chirpPulse = (chirpPulse - OnePole.ar(chirpPulse, exp(-2pi * (300 * SampleDur.ir))));


// fig 39.5: Random Gate
randGate = WhiteNoise.ar;
randGate = OnePole.ar(randGate, exp(-2pi * (3 * SampleDur.ir)));
randGate = OnePole.ar(randGate, exp(-2pi * (3 * SampleDur.ir)));
randGate = Clip.ar(noise.max(2) - 0.0008 * 1e+09, 0, 1);
randGate = OnePole.ar(randGate, exp(-2pi * (30 * SampleDur.ir)));
randGate = chirpPulse * randGate;


noise[1] = LPF.ar(LPF.ar(WhiteNoise.ar,2),2);
noise[1] = noise[1] * noise[1] * 500;


clip = Clip.ar((phasor.sum - 1) * noise[1], -0.9, 0.1);


chirpAmp = OnePole.ar(clip, exp(-2pi * (15 * SampleDur.ir)));
chirpAmp = OnePole.ar(chirpAmp, exp(-2pi * (15 * SampleDur.ir)));
chirpAmp = Clip.ar((chirpAmp * 500).max(0.1) - 0.1 * 1e+09, 0, 1);
chirpAmp = OnePole.ar(chirpAmp, exp(-2pi * (30 * SampleDur.ir)));


chirpPulse = chirpPulse * chirpAmp * 0.6;
trig = (Amplitude.kr(clip)>0.03);


// fig 39.7: Spark snap
snap = 0!2;
snap[0] = EnvGen.ar(Env.new([0,1,0], [0, 0.5]), trig);
snap[0] = snap[0] * snap[0] * snap[0] * WhiteNoise.ar * 0.5;
snap[1] = EnvGen.ar(Env.new([0,1,0], [0, 10/1000]), trig);
snap[1] = SinOsc.ar(snap[1] * 7000 + 20);
snap = snap.sum * 0.05;


// fig 39.6: Spark formant
formant = BPF.ar(snap, 1.8 * [4600, 7200, 480, 720], [5,5,7,8].reciprocal);
formant = formant[0..1].sum * 2 + formant[2] * 1.2 + formant[3] * 2.5;
formant = BPF.ar(formant, 2500, 0.5.reciprocal);


// fig 39.2 Comb unit
comb = DelayC.ar(InFeedback.ar(10), delaytime: (noise[1] + 20)/1000);
OffsetOut.ar(10, (chirpPulse + clip + snap + OnePole.ar(comb * 0.2, exp(-2pi * (3000 * SampleDur.ir)))));

comb!2;

}.play;
)

//cricket
(
a = {
	var modulator, mod1, mod2, mod3;

	// repeat time is 0.7s: equates to 1.43 Hz.
	modulator = LFSaw.ar(1.43, 1, 0.5, 0.5);
	mod2 = (modulator * 40.6 * 2pi).cos.squared;
	mod3 = modulator * 3147;
	mod3 = (mod3 * 2pi).cos + ((mod3 * 2 * 2pi).cos * 0.3);
	mod1 = ((Wrap.ar(modulator.min(0.1714) * 5.84) - 0.5).squared * (-4) + 1) * (mod2 * mod3);
	mod1 = (mod1 * 0.1)!2;
}.play;
)

// To stop:
a.free;

//cicada
(
c = {
	var sig, trig, seq, freq, mul, vals;

	trig = Impulse.kr(0.2);
	vals = [
		[0.5, 128],
		[8,6],
		[30,3]
	];
	freq = TChoose.kr(trig, vals);


	sig = WhiteNoise.ar;
	// The one pole filters in pure data and SC differ, so I changed the coefficents
	// a little. Also the  multiplication by 5 is not in the book, but helps to
	// approach the audible result of Farnells patch.
	sig = (sig - OnePole.ar(sig, exp(-2pi * (8000 * SampleDur.ir))));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (8000 * SampleDur.ir))));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = sig * 5;


	sig = BPF.ar(sig, [7500, 5500], 40.reciprocal).sum * SinOsc.ar(500);
	sig = sig * (1 / (SinOsc.ar( freq[0], 0, freq[1] ).squared + 1));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (4000 * SampleDur.ir)))) * 4.dup;
}.play;
)

// To stop:
c.free;


//housefly
(
SynthDef(\houseflyWing, { |out=0|
	var sig, downstroke, upstroke, wingFreq, wingRes;

	// this is already a preparation for fig 50.14 and is not described
	// in the pure data patch on fig 50.13
	wingFreq = In.ar(10,2);
	wingRes = In.ar(20,2);

	// Also, it is prepared for some other input from a different source,
	// to not only control the patch with the mouse movement.
	// See also the following URL for more information about the next lines:
	// http://supercollider.sourceforge.net/wiki/index.php/Boolean_logic_in_the_server
	wingFreq = Select.ar(wingFreq > 0, [K2A.ar(MouseX.kr(0, 300)), wingFreq]);
	wingRes = Select.ar(wingRes > 0, [K2A.ar(MouseY.kr(3,5)), wingRes]);

	sig = LFSaw.ar(wingFreq, 1, 0.5, 0.5);
	sig = ((sig * 0.2).min(sig * (-1) + 1)).min(sig.min(sig * (-1) + 1));
	sig = (sig * 6 - 0.5) * 2;

	downstroke = (wingRes) * sig.min(0);
	downstroke = (Wrap.ar(downstroke) * 2pi).cos * sig.min(0) * 0.5 + sig.min(0);
	upstroke = sig.max(0).cubed * 2;

	sig = downstroke + upstroke;
	sig = (sig - OnePole.ar(sig, exp(-2pi * (700 * SampleDur.ir)))).dup * 0.05;
	Out.ar(out, sig);
}).add;
x = Synth(\houseflyWing);
);
(
SynthDef(\buzzingHousefly, {
	var beatingFreq, resonanceMod;

	beatingFreq = OnePole.ar(WhiteNoise.ar, exp(-2pi * (4 * SampleDur.ir)));
	beatingFreq = OnePole.ar(beatingFreq, exp(-2pi * (4 * SampleDur.ir)));
	beatingFreq = beatingFreq * 700 + 220;

	resonanceMod = OnePole.ar(WhiteNoise.ar, exp(-2pi * (5 * SampleDur.ir)));
	resonanceMod = OnePole.ar(resonanceMod, exp(-2pi * (5 * SampleDur.ir)));

	Out.ar(10, [beatingFreq, (resonanceMod * 3) + beatingFreq]);
	Out.ar(20, (resonanceMod * 40 + 5)!2 );
}).add;
y = Synth(\buzzingHousefly);
)

//red alert
(
SynthDef(\red, {

	var env, redAlert, dfbe, aIn, bIn, cIn, aOut, bOut, cOut;

	# aIn, bIn, cIn = LocalIn.ar(7).clumps([5,1,1]);

	env = [EnvGen.ar(Env.new([0,1,1,0], [0.9, 0.3, 0.0])), EnvGen.ar(Env.new([0,1,1,0], [0.01, 0.88, 0.01]))];
	env[0] = LFSaw.ar(env[0].sqrt * 487 + 360, 1, 0.5, 0.5);
	env[0] = (env[0] - 0.5) + ((env[0] * 2 * 2pi).cos * 0.3);
	redAlert = (env[0] - OnePole.ar(env[0], exp(-2pi * (1 * SampleDur.ir)))) * env[1];
	redAlert = redAlert + (cIn * 0.006) * 0.2;


	// fig 58.6: Delay feedback element
	dfbe = 0!6;
	redAlert = redAlert + (aIn * 0.7);
	5.do{|i| dfbe[i] = DelayN.ar(redAlert[i], 0.1, [0.015, 0.022, 0.035, 0.024, 0.011][i])};
	aOut = dfbe[0..4];

	redAlert = redAlert[0..4].sum;
	redAlert = (redAlert - OnePole.ar(redAlert, exp(-2pi * (12 * SampleDur.ir))));

	dfbe[5] = redAlert + (bIn * 0.7);
	dfbe[5] = DelayN.ar(dfbe[5], 0.1, 0.061);
	# bOut, cOut = dfbe[5]!2;
	LocalOut.ar(aOut ++ bOut ++ cOut);

	redAlert = Clip.ar(redAlert * 4, -1, 1);
	redAlert = BPF.ar(redAlert, [740, 1400, 1500, 1600], (12!4).reciprocal) ++ (redAlert * 0.5);
	Out.ar(0, (redAlert.sum * 0.2)!2);

}).add;
)


// ALL HANDS!! BATTLESTATIONS!
e = Synth(\red);

//babbling R2D2
(
w = {	|period=0|
	var change, rate, sig, carrierFreq, cfRamp, carrierLvl, clRamp,
	modulatorRatio, mrRamp, modulatorIndex, miRamp, outputAmplitude, oaRamp;

	period = period * 600 + 100;

	// Calculation of a recursive working metronome (Impulse.kr) that generates its
	// changing frequency out of its own impulses.
	change = Impulse.kr(LocalIn.kr(1,10));
	rate = CoinGate.kr(1/3, change);
	rate = (TChoose.kr(rate, period/((0..1) + 1))/1000).reciprocal;
	LocalOut.kr(rate);

	# carrierFreq, cfRamp = TIRand.kr(0, [1000, 1], change);
	carrierFreq = Ramp.kr( carrierFreq / 1000, (cfRamp * period) / 1000 ) * 0.6;

	# carrierLvl, clRamp = TIRand.kr(0, [9000, 1], CoinGate.kr(1/3, change));
	carrierLvl = Ramp.kr( carrierLvl, (clRamp * period) / 1000) + 100;

	# modulatorRatio, mrRamp = TIRand.kr([800,1], CoinGate.kr(1/4, change));
	modulatorRatio = Ramp.kr(modulatorRatio, (mrRamp * period) / 1000) + 20;

	# modulatorIndex, miRamp = TIRand.kr(0, [100, 1], CoinGate.kr(1/4, change));
	modulatorIndex = Ramp.kr(modulatorIndex / 200, (miRamp * period) / 1000) + 0.2;

	# outputAmplitude, oaRamp = TIRand.kr(0!2, 1!2, CoinGate.kr(1/2, change));
	outputAmplitude = Ramp.kr(outputAmplitude, (oaRamp * period + 3) / 1000);

	// jointed FM Synthesizer
	sig = LFSaw.ar(carrierFreq, 1, 0.5, 0.5) * carrierLvl;
	sig = sig + SinOsc.ar(carrierFreq * modulatorRatio) * modulatorIndex;
	sig = cos(sig * 2pi) * outputAmplitude;

	// One pole filters:
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = OnePole.ar(sig, exp(-2pi * (10000 * SampleDur.ir)));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (100 * SampleDur.ir))));
	sig = (sig - OnePole.ar(sig, exp(-2pi * (100 * SampleDur.ir))));
	sig = sig!2 * 0.06;
}.play;
)

// period controls the talk-speed. range: 0-1. 0 matches to fast, 1 to slow:
w.set(\period, 1);
w.set(\period, 0);
w.set(\period, 0.5);
w.set(\period, 0.7);
w.set(\period, 0.3);

// To stop:
w.free;

