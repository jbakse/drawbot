Serial arduinoSerial;

class Bot_Driver {
	int currentInstruction;
	boolean running = false;
	
	Bot_Driver(PApplet _applet) {

		arduinoSerial = new Serial(_applet, Serial.list()[0], 9600);

		arduinoSerial.bufferUntil('\n');
		currentInstruction = 0;
		running = false;
	}


		
	void serialEvent(Serial port) {
		String inString = arduinoSerial.readStringUntil('\n');
		inString = trim(inString);
		println("Arduino Said: "+inString);
		if (inString.equals("done")) {
			if (running) sendNext();
		}
	}

	void start(){
		currentInstruction = 0;
		running = true;
		sendNext();
	}

	void stop(){
		running = false;
	}

	void sendNext(){
		if (instructionSet == null) return;
		if (currentInstruction >= instructionSet.instructions.size()) return;
		println("telling arduino: "+((Instruction)instructionSet.instructions.get(currentInstruction)).toCommand());
		arduinoSerial.write(((Instruction)instructionSet.instructions.get(currentInstruction)).toCommand());
		currentInstruction++;
		if (currentInstruction == instructionSet.instructions.size()) stop();
	}


}