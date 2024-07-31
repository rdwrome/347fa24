( // registering MIDI responders
MIDIIn.connectAll; // connect incoming ports
MIDIFunc.cc({arg value, ccNumber; // listen to control change messages
	"Control Change message received !".postln;
	[value, ccNumber].postln;	// do sth with the value and the controller's number
}, nil); // nil stands for listening to any cc message coming from everywhere
MIDIFunc.sysex({arg data; // listen to sysex messages
	"System Exclusive received !".postln;
	[data].postln;	// do sth with the message
},nil); // listen to any message coming from everywhere
)
