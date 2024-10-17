( // accessing remote data from random.org
var data = "curl \"http://www.random.org/sequences/?min=1&max=52&col=1&format=plain&rnd=new\" ".unixCmdGetStdOutLines;
data.postln;
)
