( // using custom delimiters
var data = Array.fill(1000,{rrand(0,1000)}); // an array of random values
var file = File("dataset.dat".absolutePath,"w"); // open for writing operations 
data.do{ arg item;
	file.write(item.asString + $@); // write data adding a custom delimiter
};
file.close;  // close file when done
// read data with FileRead
data = FileReader.read("dataset.dat".absolutePath, delimiter: $@);
data[0].postln; // print data in the post window
)
