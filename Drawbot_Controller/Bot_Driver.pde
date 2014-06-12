Serial arduinoSerial;

class Bot_Driver
{
	int currentInstruction;
	boolean running = false;

	Bot_Driver(PApplet _applet)
	{
		try {
			println("Serial List");
			println(Serial.list());

//			arduinoSerial = new Serial(_applet, Serial.list()[0], 115200);
			arduinoSerial = new Serial(_applet, "/dev/cu.usbmodem1411", 115200);
			arduinoSerial.bufferUntil('\n');
		} catch (Exception e) {
			println("Problem connecting to arduino");
		} finally {
			
		}
		

		
		currentInstruction = 0;
		running = false;
	}



	void serialEvent(Serial p)
	{
		println("serialEvent");
		String inString = arduinoSerial.readStringUntil('\n');
		println("read string success");
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
		
		// sendNext();
		// sendNext();
		// sendNext();
		// sendNext();

	}

	void pause() {
		running = false;
	}

	void resume() {
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
		print("telling arduino: " + i.toCommand());
		arduinoSerial.write(i.toCommand());
	}


}
