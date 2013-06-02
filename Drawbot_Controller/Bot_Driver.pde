// Serial arduinoSerial;

// boolean flagSendNext;

// class Bot_Driver {
// 	ArrayList instructions;
// 	int currentInstruction;
// 	boolean flagSendNext = false;
	
// 	Bot_Driver() {
// 		arduinoSerial = new Serial(this, Serial.list()[0], 9600);
// 		arduinoSerial.bufferUntil('\n');

// 		flagSendNext = false;
// 	}

// 	void step(){
// 		// if (flagSendNext) {
// 		// 	moveTo(drawPoints[currentPoint++]);
// 		// 	flagSendNext = false;
// 		// }
// 	}


	

// 	BotController() {
// 		instructions = new ArrayList();
// 		currentInstruction = 0;
// 	}

// 	void loadSegments(ArrayList _segments) {
// 		instructions = new ArrayList();
// 		currentInstruction = 0;

// 	//reset
// 	instructions.add(penInstruction(penUpAngle));
// 	instructions.add(speedInstruction(desiredSpeed));

// 	instructions.add(resetInstruction());

// 	//draw
// 	PVector pos = new PVector(0, 0);
// 	boolean penDown = false;
// 	for (int i = 0; i < _segments.size() * timeSliderValue; i++) {
// 		Segment seg = (Segment)_segments.get(i);
// 		if (seg.type == "move") {
// 			if (penDown){
// 				instructions.add(penInstruction(penUpAngle));
// 				penDown = false;
// 			}
// 		}
// 		else if (seg.type == "draw") {
// 			if (penDown == false){
// 				instructions.add(penInstruction(penDownAngle));
// 				penDown = true;
// 			}
// 		}
// 		instructions.add(moveInstruction(seg.x - pos.x, seg.y - pos.y));
// 		pos.x = seg.x;
// 		pos.y = seg.y;
// 	}

// 	instructionListBox.clear();
// 	for (int i=0;i<instructions.size();i++) {
// 		ListBoxItem lbi = instructionListBox.addItem((String)instructions.get(i), i);
// 		// lbi.setColorBackground(0xffff0000);
// 	}
// }

// String penInstruction(int _a) {
// 	return "1,"+_a+",";
// }

// String moveInstruction(float _x, float _y) {
// 	int x = (int)(_x * drawScale);
// 	int y = (int)(_y * drawScale);
// 	return "2,"+x+","+y+",";
// }

// String resetInstruction() {
// 	return "3,";
// }

// String speedInstruction(int _s) {
// 	return "8,"+_s+",";
// }

// void step() {
// 	if (flagSendNext) {
// 		flagSendNext = false;
// 		sendNext();
// 	}
// }

// void start() {
// 	currentInstruction = 0;
// 	flagSendNext = true;
// }


// void sendNext() {
// 	if (currentInstruction < instructions.size()) {
// 		String instruction = (String)instructions.get(currentInstruction);
// 		println("Sending: "+instruction);
// 		arduinoSerial.write(instruction);
// 		currentInstruction++;
// 	}
// 	else {
// 		println("Sent all Instructions");
// 	}
// }

// void serialEvent(Serial port) {
// 	String inString = arduinoSerial.readStringUntil('\n');
// 	inString = trim(inString);
// 	println("Arduino Said: "+inString);
// 	if (inString.equals("done")) {
// 		flagSendNext = true;
// 	}
// }




// }