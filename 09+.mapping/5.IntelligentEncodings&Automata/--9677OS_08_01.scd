( // calculate statistical meta-data
var data, mode, leastProbableNumber, head, tail, mean, median, range, iqr, variance, deviation;

// first load and prepare our dataset
data = CSVFileReader.read("arrhythmia.data".absolutePath,true,true); // read from file
data = data[0].collect(_.asInteger); // consider just a chunk and convert its elements to Integers
data = data.select(_!=0); // remove zeros

// calculate meta-data
mode = data.maxItem({arg item; data.occurrencesOf(item)});
("Mode is: " + mode).postln;
leastProbableNumber = data.minItem({arg item; data.occurrencesOf(item)});
("Least Probable number is: " + leastProbableNumber).postln;
head = data.select{arg item; data.occurrencesOf(item) >= 6}; // only those values that appear at least 6 times
("Head is: " + head.as(IdentitySet)).postln;
tail = data.reject{arg item; data.occurrencesOf(item) >= 6}; // values that appear less than 6 times
("Tail is: " + tail.as(IdentitySet)).postln;
mean = data.sum / data.size; // the sum of all data divided by the size of the dataset
("Mean is: " + mean).postln;
median = data.sort[data.size/2]; // the 'middle' element when the array is sorted
("Median is: " + median).postln;
range = data.max - data.min; // range
("Range is: " + range).postln;
iqr = data.at(( (data.size/4) .. ((data.size*3)/4) )); // return an array with only the second and the third quartilion
iqr = iqr.max - iqr.min; // calculate iqr range
("Interquartile Range is: " + iqr).postln;
variance = (data.collect{arg item; (item-mean).squared}).sum/data.size; // calculate variance
("Variance is: " + variance).postln;
deviation = variance.sqrt; // calculate deviation
("Deviation is: " + deviation).postln;
)
