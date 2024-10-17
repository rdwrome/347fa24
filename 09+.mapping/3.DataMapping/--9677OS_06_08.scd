( // send an OSC message to the Client
var receiver = NetAddr.new("127.0.0.1", 57120); // localhost
var data = Int8Array.fill(100,{rrand(0,100)}); // 8bit data
receiver.sendMsg("/msg/test", data); // send OSC message
)
