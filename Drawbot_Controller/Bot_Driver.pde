Serial arduinoSerial;

boolean flagSendNext;

class Bot_Driver {
	Bot_Driver() {
		arduinoSerial = new Serial(this, Serial.list()[0], 9600);
		arduinoSerial.bufferUntil('\n');

		flagSendNext = false;
	}
}