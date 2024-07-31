3.linlin(-1,5,10,20); // map a value if the input range is -1,5the output 10,20 and assuming linear input/output distributions
[5,6,2,10,4].lincurve(-10,10,0,1,-8); // map all elements of an array in the -5,10 input range to an 0,1 exponential output range
{SinOsc.ar(SinOsc.ar(1).lincurve(-1,1,100,500,8))}.play // map the output of a UGen to a custom range using a custom exponential disctribution