( // sending MIDI messages
var midi, data, sysExPacket;
midi = MIDIOut(0); // assuming a virtual midi port at index 0
midi.control(10,34,124); // send 124 at cc34 channel 10
data = Int8Array.fill(15,{rrand(0,100)}); // generate data
sysExPacket = data.insert(0,0xf0).add(0xf7); // format data as sysEx
midi.sysex(sysExPacket); // send a syxEx packet
)
