( // respond to an incoming OSC message
OSCFunc({ arg msg; 
	msg.postln;  // print the message bundle
},'/msg/test'); // listen to /msg/test message
)