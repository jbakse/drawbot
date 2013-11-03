Serial arduinoSerial;

class Bot_Driver
{
	int currentInstruction;
	boolean running = false;

	Bot_Driver(PApplet _applet)
	{
		try {
			arduinoSerial = new Serial(_applet, Serial.list()[0], 9600);
			arduinoSerial.bufferUntil('\n');
		} catch (Exception e) {
			println("Problem connecting to arduino");
		} finally {
			
		}
		

		
		currentInstruction = 0;
		running = false;
	}



	void serialEvent(Serial port)
	{
		String inString = arduinoSerial.readStringUntil('\n');
		inString = trim(inString);
		println("Arduino Said: " + inString);
		if (inString.equals("done")) {
			if (running) sendNext();
		}
	}

	void start()
	{
		currentInstruction = 0;
		running = true;
		sendNext();
		sendNext();
		sendNext();
		sendNext();
	}

	void stop()
	{
		running = false;
	}

	void sendNext()
	{
		if (instructionSet == null) return;
		if (currentInstruction >= instructionSet.instructions.size()) return;
		sendInstruction((Instruction)instructionSet.instructions.get(currentInstruction));
		currentInstruction++;
		if (currentInstruction == instructionSet.instructions.size()) stop();
	}

	void sendInstruction(Instruction i)
	{
		println("telling arduino: " + i.toCommand());
		arduinoSerial.write(i.toCommand());
	}


}