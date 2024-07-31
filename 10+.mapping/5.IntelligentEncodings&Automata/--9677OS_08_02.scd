( // calculare a histogram
var data, histogram, histSize;
data = "curl \"http://www.random.org/integers/?num=1000&min=-100&max=100&col=1&base=10&format=plain&rnd=new\" ".unixCmdGetStdOutLines; // retrieve random numbers in the range (-100,100) from random.org
data = data.collect(_.asInteger); // convert to integers
histSize = data.max-data.min + 1; // calculate the size 
histogram = Array.fill(histSize,{0}); // a signal with as many elements as the range of values we are interested in
data.do({ arg item;  
	var count, histoIndex; 
	histoIndex = item + data.min.abs; // to compensate for negative items
	count = histogram.at(histoIndex); // read previous value
	histogram.put(histoIndex, count + 1); // increment it
});
histogram.plot().domainSpecs_([-100,100,\lin,1].asSpec); // make a histogram
)
