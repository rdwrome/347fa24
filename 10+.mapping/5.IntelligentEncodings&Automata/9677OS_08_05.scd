( // intelligent encoder 

// datasets
var dataset = Array.fill(100,{rrand(1,14)}); // the data to map
var major = Scale.major; // a major scale
var minor = Scale.minor; // a minor scale

// encoding functions
var majorFunc = { // function to return a C major scale frequency
	arg table, value; // table should be shorted with the most probable values first 
	var degree, freq;
	degree = table.detectIndex{arg i; i==value}; // convert value to index
	degree = [0,2,4,6,1,3,5,7][degree]; // return the appropriate scale degree
	freq = major.degreeToFreq(degree,261,1); // convert degree to frequency for a fundamental of C
	("C major's scale degree: " + degree).postln; // post info
	freq; // return frequency
};

var minorFunc = { // function to return a Eb minor scale frequency
	arg table, value; // table should be shorted with the most probable values first
	var degree, freq;
	degree = table.detectIndex{arg i; i==value}; // convert value to index
	degree = [0,2,4,6,1,3,5,7][degree]; // return the appropriate scale degree
	freq = minor.degreeToFreq(degree,311,1); // convert degree to frequency for a fundamental of Eb
	("Eb minor's scale degree: " + degree).postln; // post info
	freq; // return frequency
};

var randFunc = {  // function to generate a random frequency 
	var freq = rrand(200,700); // generate a random frequency in the 200,700 range
	("random frequency selected: " + freq).postln; // post info
	freq; // return frequency
};

// function calculate the head and Tail of the dataset
var headTailFunc = { 
	arg data; // calculate head and tail of the dataset
	var head, tail, sorted;
	sorted = data.asBag.contents.asSortedArray.sort({arg a,b; b[1]<a[1]}).collect(_[0]); // sort dataset so that the most probable values are first
	head = sorted.clipAt((0 .. 6)); // the 7 most probable values are the head 
	tail = sorted.clipAt((7 .. 13)); // the rest are the tail
	[head,tail]; // return an array with the head and tail
};

 // function to calculate the probability of the next 3 consecutive values to be in the head
var probFunc = { arg data, head; 
	var prob;
	prob = head.sum(data.occurrencesOf(_)/data.size); // probability of next value to be in head
	prob.cubed; // return the probability of 3 consecutives values to be in the head
};

// mapping function
var mappingFunc = { arg data;
	var head, tail, prob, choice, freq, index;
	#head, tail = headTailFunc.(data); // calculate head and tails
	prob = probFunc.(data,head); // calculate the probality of the next 3 consecutive values to be in the head
	index = data.size.rand; // a random index in the dataset
	choice = data[index]; // pick a random value at index
	freq = if (head.includes(choice)) { // if chosen datum is in the head
		majorFunc.(head,choice); // call majorFunc
	} { 
		if (prob > 0.29) { // else if the probability of the next 3 consecutive to be in the head is more than 29%
			randFunc.(); // produce a random value
		} { // else 
			minorFunc.(tail,choice); // call minorFunc
		}
	};
	data.removeAt(index); // remove datum from dataset
	freq; // return frequency
};

// sound
fork{100.do{ var freq;
	freq = mappingFunc.(dataset); // encode data
	{SinOsc.ar(freq) * Line.ar(1,0,0.4,doneAction:2)}.play; // play sound
	[0.5,0.25,1].wchoose([0.6,0.3,0.1]).wait; // wait 
}};
)