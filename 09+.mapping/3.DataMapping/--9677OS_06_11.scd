( // reading bytes from some serial bus 
var port = SerialPort( /* port path here */, baudrate: 9600, crtscts: true /* enable hardware data flow control */);
fork{5.do{ // read 5 next bytes
	port.next.postln; // read next byte
	1.wait; // wait 1 second;
}};
SerialPort.closeAll; // close all ports when done;
)
