// analysis proposal due next week: a link to what you're thinking about in canvas and why (no markdown necessary)

//adapted from: https://en.wikibooks.org/wiki/Designing_Sound_in_SuperCollider
//a plug for pd
// BOOT

// recirculating schroeder reverb with Ndef and DELAYC
b = Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/windchimes.wav");

(
Ndef(\verb, {
	var input, output, delrd, sig, deltimes;

	// Choose which sort of input you want by (un)commenting these lines:
	input = Pan2.ar(PlayBuf.ar(1, b, loop: 1), -0.5); // buffer playback, panned halfway left
	//input = SoundIn.ar([0,1]); // TAKE CARE of feedback - use headphones
	//input = Dust2.ar([0.1, 0.01]); // Occasional clicks

	// Read our 4-channel delayed signals back from the feedback loop
	delrd = LocalIn.ar(4);

	// This will be our eventual output, which will also be recirculated
	output = input + delrd[[0,1]];

	// Cross-fertilise the four delay lines with each other:
	sig = [output[0]+output[1], output[0]-output[1], delrd[2]+delrd[3], delrd[2]-delrd[3]];
	sig = [sig[0]+sig[2], sig[1]+sig[3], sig[0]-sig[2], sig[1]-sig[3]];
	// Attenutate the delayed signals so they decay:
	sig = sig * [0.4, 0.37, 0.333, 0.3];

	// Here we give delay times in milliseconds, convert to seconds,
	// then compensate with ControlDur for the one-block delay
	// which is always introduced when using the LocalIn/Out fdbk loop
	deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;

	// Apply the delays and send the signals into the feedback loop
	LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));

	// Now let's hear it:
	output

}).play
)

Ndef(\verb).free;

//throwback dial tone and DICTIONARIES
(
Ndef(\dialtone, {
	// Note: the array here specifies two frequencies, so we get two separate channels.
	// We sum the two channels so they combine into one signal - otherwise we
	// would hear one note on left, one note on right.
	Pan2.ar(SinOsc.ar([350, 440], 0, 0.2).sum)
}).play
)

Ndef(\dialtone).free;

// Dual Tone MultiFrequency phone
(
// This data structure (like a "hashtable" or "associative array" in other languages)
// maps from a phone key to a pair of frequencies in Hz.
// We can push these frequencies to a synth.
~tbl = IdentityDictionary[
	$1 -> [[697, 1209]],
	$2 -> [[770, 1209]],
	$3 -> [[852, 1209]],
	$4 -> [[697, 1336]],
	$5 -> [[770, 1336]],
	$6 -> [[852, 1336]],
	$7 -> [[697, 1477]],
	$8 -> [[770, 1477]],
	$9 -> [[852, 1477]],
	$* -> [[697, 1633]],
	$0 -> [[770, 1633]],
	$# -> [[852, 1633]],
	$A -> [[941, 1209]],
	$B -> [[941, 1336]],
	$C -> [[941, 1477]],
	$D -> [[941, 1633]]
];

// Here we define a SynthDef which plays a single "number" at a time.
// Note that our strategy here is a bit different from the PD code in the book:
//   there, a single pair of sine-wave oscillators was re-used for each number,
//   whereas here, we create (and later free) an individual synth for each number.
SynthDef(\dtmf, {|freq=#[770, 1633], out=0, amp=0.2, gate=1|
	var son, env;
	son = SinOsc.ar(freq, 0, amp).sum;
	env = EnvGen.ar(Env.asr(0.001, 1, 0.001), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(son * env * amp));
}).add;
)

// Check that it works:
x = Synth(\dtmf) // create
x.set(\gate, 0)  // free

(
// This pattern generates a random "phone number" and dials it
Pbind(
	\instrument, \dtmf,
	\dur, Pwhite(0.2, 0.5, inf),
	\sustain, 0.15,
	\amp, 0.3,
	\freq, Prand(~tbl.asArray, 13)
).play;
)

(
// You could even dial a specific number:
Pbind(
	\instrument, \dtmf,
	\dur, Pwhite(0.2, 0.5, inf),
	\sustain, 0.15,
	\amp, 0.3,
	\freq, Pseq("3363551993".collectAs({|digit| ~tbl[digit] }, Array))
).play;
)

// MAKE IT YOUR OWN

// uk ambulance alarm
(
Ndef(\alarm, {
	var tone1 = SinOsc.ar(600);
	var tone2 = SinOsc.ar(800);
	// We switch between the tones using LFPulse, but soften the crossfade with the low-pass:
	var control = LPF.kr(LFPulse.kr(2), 70);
	var out = SelectX.ar(control, [tone1, tone2]);
	Pan2.ar(out * 0.1)
}).play
)

// us police siren with FREEVERB
(
SynthDef(\siren, { |rate=0.1|
	var freq = LFPulse.kr(rate, 0.99, 0.4).lagud(0.4 / rate, 0.6 / rate) * 800 + 300;
	var son  = LFPulse.ar(freq, 0.99, 0.2).lagud(0.4 / freq, 0.6 / freq) * 2 - 1;

	// This filtering is a simple approximation of the plastic horn acoustics:
	son = BPF.ar(son.clip2(0.2), 1500, 1/4) * 4;

	// delay and reverb, to simulate the environment in which we hear the siren
	son = son + DelayC.ar(son, 0.1, 0.1, 0.3);
	son = son + FreeVerb.ar(son);

	Out.ar(0, Pan2.ar(son * 0.4));
}).add;
)

x = Synth(\siren);

x.set(\rate, 3);
x.set(\rate, 0.1);

// alarm with STEPPER
(
Ndef(\alarm, {
	var tone1 = SinOsc.ar(723);
	var tone2 = SinOsc.ar(932);
	var tone3 = SinOsc.ar(1012);
	// Stepper is perfect for stepping through the options:
	var control = LPF.kr(Stepper.kr(Impulse.kr(2), 0, 0, 2), 70);
	var out = SelectX.ar(control, [tone1, tone2, tone3]);
	Pan2.ar(out * 0.1)
}).play
)

// alarm with mousex mapped to duty mapped to Duty/Dseq
(
Ndef(\alarm, {
	var freq, out, operations;
	freq = Duty.kr(0.05, 0, Dseq([723, 932, 1012], inf));
	freq = LPF.kr(freq, 70);
	out = SinOsc.ar(freq);
	operations = [out, (out * pi).sin, (out * pi).cos, ((out+0.25) * pi).cos];
	out = Select.ar(MouseX.kr(0,4).poll, operations);
	Pan2.ar(out * 0.1)
}).play
)

// metallic resonance with KLANK and its cousins
(
{
	var son;
	son = Klank.ar(`[
		[521, 732, 934],  // freqs
		[0.7, 0.45, 0.25],// amps
		[0.8, 0.8, 0.8]   // ring times
		],
	Impulse.ar(1));
	Pan2.ar(son * 0.2)
}.play
)

// phonebell with GROUP
(
SynthDef(\phonebell, { |gate=1, freq=465, strength=1, decay=3, amp=1|
	var trigs, striker, son;
	trigs = Impulse.ar(14) * gate;
	striker = WhiteNoise.ar(EnvGen.ar(Env.perc(0.0000001, 0.01), trigs));
	son = Klank.ar(`[
		// frequency ratios
		[0.501, 1, 0.7,   2.002, 3, 9.6,   2.49, 11, 2.571,  3.05, 6.242, 12.49, 13, 16, 24],
		// amps
		[0.002,0.02,0.001, 0.008,0.02,0.004, 0.02,0.04,0.02, 0.005,0.05,0.05, 0.02, 0.03, 0.04],
		// ring times - "stutter" duplicates each entry threefold
		[1.2, 0.9, 0.25, 0.14, 0.07].stutter(3)
		]
	, striker, freq, 0, decay);
	Out.ar(0, Pan2.ar(son * amp));
}).add
)

// Here we start the phone bells constantly ringing. We put them in a group for convenience
~bellgroup = Group.new(s);
~bell1 = Synth(\phonebell, [\freq, 650], ~bellgroup);
~bell2 = Synth(\phonebell, [\freq, 653], ~bellgroup);


// OK, shush for now
~bellgroup.set(\gate, 0);

// Now let's turn them on and off in a telephone-like pattern.
// This could be done using a synth, but let's use a (client-side) pattern:
p = Pbind(\type, \set, \id, ~bellgroup.nodeID, \args, [\gate], \gate, Pseq([1,0], inf), \dur, 2).play
p.stop;

// bouncing ball (like maths makenoise module)
(
Ndef(\bouncer, {

var bounceperiod, bouncetrigs, amp, fm, mainosc;

bounceperiod = Line.kr(0.3, 0, 3, doneAction: 2);

bouncetrigs = Impulse.kr(bounceperiod.reciprocal.min(30));

amp = EnvGen.ar(Env.perc(0.001, 0.0), bouncetrigs);
amp = Amplitude.ar(amp, 0, bounceperiod) * Line.kr(1, 0.05, 3);

fm =
	SinOsc.ar(120).range(0, Line.ar(1, 0, 3))
		+
	(amp * Line.ar(1, 0, 3).cubed * 130 + 80)
;

mainosc = SinOsc.ar(fm, pi/2);

amp * mainosc;
}).play
)

// hit a can
(
x = { |t_trig=0|
	// This line just creates a sharp little spike whenever we want:
	var strike = EnvGen.ar(Env.perc(0.0001, 0.001, 0.1), t_trig);
	// here's the resonances:
	var son = Ringz.ar(strike, [359, 426, 1748, 3150], 0.2).sum;
	// some distortion livens up the spectrum a little:
	son = HPF.ar(son.clip2(0.6), 300);
	son * 0.2
}.play;
)
x.set(\t_trig, 1); // Run this line to hit the can!

// can fall and roll
(
~regularroll = { |rate = 1|
	// In the original code, Andy uses a master phase control,
	// wrapping and re-scaling it before differentiating, to produce
	// a repeating but disorderly set of impulses.
	// Here we do it differently - we use Impulse.kr to generate the
	// impulses directly.
	// We evaluate this function multiple times using .dup so that
	// we get a whole set of impulses with random phase positions.
	{
		Impulse.kr(rate, 1.0.rand, 1.0.bilinrand)
	}.dup(10).sum
};
~regularroll.plot(2);
);
(
// This signal contribution to rolling signature based on Mathias Rath's idea - see 'The Sounding Object'
// (ajf2009) with K2A and Ringz
//
~irregularground = { |rate=10|
	var trigs = Dust.kr(rate);
	EnvGen.ar(

		Env([0,0,-1,1.5,-1,1,0], [0.1, 0.1, 0.001, 0.001, 0.1, 0.1], 'sine'),
		trigs
	) * 0.1
};
~irregularground.plot(4)
);
(
x = {
	var rate, strike, son;
	// rate of motion starts fast and tails off
	rate = XLine.kr(4, 0.001, 8, doneAction: 2);
	// This rate affects both the regular rolling, and the irregular ground contacts.
	strike =
		~irregularground.(rate*2) * 0.04
			+
		K2A.ar(~regularroll.(rate) * 0.1)
			;
	// Force the strikes to die off in intensity:
	strike = strike * XLine.ar(1, 0.0001, 8);
	// And here are the tin-can resonances as in fig 31.3:
	son = Ringz.ar(strike, [359, 426, 1748, 3150], 0.2).sum;
	son = HPF.ar(son.clip2(0.6), 300);
	son * 0.2
}.play;
)

//fire
(
~firegen = {
	var trigs, durscale, resfreq;
	var noise, hissing, crackles, lapping;
	// A common noise source
	noise = WhiteNoise.ar;
	// Hissing
	hissing = HPF.ar(noise, 1000) * LFNoise2.kr(1).squared.squared;
	// Crackle
	trigs = Dust.kr(3);
	durscale = TRand.kr(1, 1.5, trigs); // vary duration between default 20ms and 30ms
	resfreq = TExpRand.kr(100, 1000, trigs); // different resonant frequency for each one
	crackles = noise * EnvGen.ar(Env.perc(0, 0.02, curve: 0), trigs, timeScale: durscale);
	crackles = crackles + BPF.ar(crackles, resfreq, 20);
	// Flame
	lapping = LeakDC.ar(LeakDC.ar(BPF.ar(noise, 30, 0.2) * 50).clip2(0.9)) * 0.5;
	// Combine them:
	([crackles, hissing, lapping] * [0.1, 0.3, 0.6]).sum * 3
};
~firegen.play
)

//bubbles with pbind
(
SynthDef(\bubblebub, {	|out=0, t_trig=0, attack=0.01, decay=0.08, pitchcurvelen=0.1, freq=1000, doneAction=0, amp=0.1|
	var pitch, son;
	amp   = amp * EnvGen.ar(Env.perc(attack, decay).delay(0.003), t_trig, doneAction: doneAction);
	pitch = freq * EnvGen.ar(Env.new([0,0,1],[0,1]).exprange(1, 2.718), t_trig, timeScale: pitchcurvelen);
	son = SinOsc.ar(pitch);
	// high-pass to remove any lowpitched artifacts, scale amplitude
	son = HPF.ar(son, 500) * amp * 10;
	Out.ar(out, Pan2.ar(son));
}).add
);
(
p = Pbind(
	\instrument, \bubblebub,
	\sizefactor, Pwhite(0.0,1,inf),
	\dur, Pgauss(0.3, 0.2),
	\freq,  Pkey(\sizefactor).linexp(0, 1, 1000, 3000),
	\amp ,  Pkey(\sizefactor).linlin(0, 1, 0.15, 0.04),
	\decay, Pkey(\sizefactor).linlin(0, 1, 0.05, 0.08),
	\doneAction, 2
).play
)
p.stop

///MAKE IT YOUR OWN