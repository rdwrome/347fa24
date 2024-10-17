( // reading chunks of data
var file, data;
file = File("dataset.dat".absolutePath,"r"); // open for reading operations 
fork{loop{ // use a routine to read a chunk at a time
	if (file.pos != file.length) { // if there are data left
		data = file.getLine; // get a new line of data
		data.postln; // do something with data
	} {  // close file and stop routine when done
		"done !".postln;
		file.close;  
		thisThread.stop;
	};
	0.1.wait;  // wait before iterating through the remaining data
}};
)
