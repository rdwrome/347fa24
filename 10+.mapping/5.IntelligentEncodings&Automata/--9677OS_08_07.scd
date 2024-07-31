( // a simple Neural Network Example
var net, sample; 
net = NeuralNet(2,20,1,0.01,1.0); // 2 ins, 1 out, 20hidden
sample = [ [[1,0],[1]], [[0.5,0.5],[0.5]], [[1,0.5],[0.5]], [[0,1],[0]] ]; // the sample
net.trainExt(sample,0.01,10000); // train over 10000 epochs or until the error is less that 0.01
// test
net.calculate([1,0]).postln;
net.calculate([0.5,0.5]).postln;
net.calculate([0,1]).postln;
net.calculate([0.75,0.25]).postln;
)
