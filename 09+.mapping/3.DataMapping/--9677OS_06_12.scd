( // polling data from Arduino
var arduino, loop; 
// connect on given port and baud rate set to 57600
arduino = SCPyduino.new("/dev/tty.usbmodem411", 57600); 
arduino.analog[0].active_(1); // activate polling on Analog pin 0
loop = fork{1000.do{ // read 1000 bytes from arduino
	arduino.iterate; // sync with arduino's clock
	arduino.analog[0].value; // do sth with data read
}};
arduino.close; // close when done
)
