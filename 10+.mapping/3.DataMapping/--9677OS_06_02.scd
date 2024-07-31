( // read a file
var file = File("dataset.dat".absolutePath,"r"); // open for reading operations 
var data = file.readAllString;
data.postln;
file.close;  // close file when done
)