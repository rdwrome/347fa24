( // storing data to a local file
var data = Array.fill(1000,{rrand(0,1000)}); // an array of random values
var file = File("dataset.dat".absolutePath,"w"); // open for writing operations 
data.do{ arg i;
	file.write(i + "\n"); // write data adding new line character to the end
};
file.close;  // close file when done
)
