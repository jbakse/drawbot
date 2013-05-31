import controlP5.*;
import geomerative.*;
import processing.serial.*;

Settings settings;
User_Interface userInterface;
Bot_Driver botDriver;
Parser parser;
Visualizer visualizer;
Instruction_Set instructionSet;


void setup() {
	RG.init(this);
	cp5 = new ControlP5(this);
	
	size(800, 600);
	
	//initialize components
	settings = new Settings();
	userInterface = new UserInterface();
	botDriver = new Bot_Driver();
	parser = new Parser();
	visualizer = new Visualizer();

	instructionSet = parser.parseSVG("default.svg");
}

//////////////////////////////////////////////////////
// Button Handlers

public void openSVG(int theValue) {
	selectInput("Select a file to process:", "svgSelection");
}

void svgSelection(File selection) {
	if (selection == null) {
		println("File not Selected.");
		return;
	} 
	println("User Selected: " + selection.getAbsolutePath());
	instructionSet = parser.parseSVG(selection.getAbsolutePath());
}


public void openBOT(int theValue) {
	selectInput("Select a file to load:", "botFileSelection");
}


void botFileSelection(File selection) {
	if (selection == null) {
		println("File not Selected.");
		return;
	} 
	println("User Selected: " + selection.getAbsolutePath());
	instructionSet = parser.parseBOT(selection.getAbsolutePath());
}





public void scalePointPaths(int theValue) {
	//  pointPaths = scalePointPaths(pointPaths, 500, 500);
}

public void startBot(int theValue) {
	botController.start();
}

//////////////////////////////////////////////////////
// Vector Data





//////////////////////////////////////////////////////
// Draw Interface


void draw() {
	background(50);

	// preview
	fill(0);
	noStroke();
	rect(previewRect.x, previewRect.y, previewRect.w, previewRect.h);

	//list
	fill(0);
	noStroke();
	rect(listRect.x, listRect.y, listRect.w, listRect.h);

	//controls
	//self drawn
	fill(255);

	//draw vector data
	pushMatrix();
	{
	translate(10, 10);
	noFill();
	PVector pos = new PVector(0, 0);
	for (int i = 0; i < segments.size() * timeSliderValue; i++) {
		Segment seg = (Segment)segments.get(i);
		if (seg.type == "move") {
		stroke(200, 100, 100);
		}
		else if (seg.type == "draw") {
		stroke(100, 200, 100);
		}
		line(pos.x, pos.y, seg.x, seg.y);
		pos.x = seg.x;
		pos.y = seg.y;
	}
	}
	popMatrix();

	// if (flagSendNext) {
	// 	moveTo(drawPoints[currentPoint++]);
	// 	flagSendNext = false;
	// }

	botController.step();
}




void serialEvent(Serial myPort) {
	println("serial event");
	botController.serialEvent(myPort);
}





class Segment {
	String type; //move, draw
	float x;
	float y;
	Segment (String _type, float _x, float _y) {
	type = _type; 
	x = _x; 
	y = _y;
	}
}

class BotController {
	ArrayList instructions;
	int currentInstruction;
	boolean flagSendNext = false;

	BotController() {
	instructions = new ArrayList();
	currentInstruction = 0;
	}

	void loadSegments(ArrayList _segments) {
	instructions = new ArrayList();
	currentInstruction = 0;

	//reset
	instructions.add(penInstruction(penUpAngle));
	instructions.add(speedInstruction(desiredSpeed));

	instructions.add(resetInstruction());

	//draw
	PVector pos = new PVector(0, 0);
	boolean penDown = false;
	for (int i = 0; i < _segments.size() * timeSliderValue; i++) {
		Segment seg = (Segment)_segments.get(i);
		if (seg.type == "move") {
		if (penDown){
			instructions.add(penInstruction(penUpAngle));
			penDown = false;
		}
		}
		else if (seg.type == "draw") {
		if (penDown == false){
			instructions.add(penInstruction(penDownAngle));
			penDown = true;
		}
		}
		instructions.add(moveInstruction(seg.x - pos.x, seg.y - pos.y));
		pos.x = seg.x;
		pos.y = seg.y;
	}

	instructionListBox.clear();
	for (int i=0;i<instructions.size();i++) {
		ListBoxItem lbi = instructionListBox.addItem((String)instructions.get(i), i);
		// lbi.setColorBackground(0xffff0000);
	}
	}

	String penInstruction(int _a) {
	return "1,"+_a+",";
	}

	String moveInstruction(float _x, float _y) {
	int x = (int)(_x * drawScale);
	int y = (int)(_y * drawScale);
	return "2,"+x+","+y+",";
	}

	String resetInstruction() {
	return "3,";
	}

	String speedInstruction(int _s) {
	return "8,"+_s+",";
	}

	void step() {
	if (flagSendNext) {
		flagSendNext = false;
		sendNext();
	}
	}
	
	void start() {
	currentInstruction = 0;
	flagSendNext = true;
	}
	
	
	void sendNext() {
	if (currentInstruction < instructions.size()) {
		String instruction = (String)instructions.get(currentInstruction);
		println("Sending: "+instruction);
		arduinoSerial.write(instruction);
		currentInstruction++;
	}
	else {
		println("Sent all Instructions");
	}
	}

	void serialEvent(Serial port) {
	String inString = arduinoSerial.readStringUntil('\n');
	inString = trim(inString);
	println("Arduino Said: "+inString);
	if (inString.equals("done")) {
		flagSendNext = true;
	}
	}
}



public void moveTo(PVector p) {
	int dX = (int)((currentLoc.x - p.x)*5);
	int dY = (int)((currentLoc.y - p.y)*5);
	currentLoc.x = p.x;
	currentLoc.y = p.y;
	println("Compy Said: 2," + dX + "," + dY + "\n");
	arduinoSerial.write("2," + dX + "," + dY + "\n");
}


void keyPressed() {
	if (key == CODED) {
	if (keyCode == UP) {
		arduinoSerial.write("2,0,-10,");
		} else if (keyCode == DOWN) {
		arduinoSerial.write("2,0,10,");
		} 
	}
	}




// RPoint[][] scalePointPaths(RPoint[][] _inPoints, float _targetWidth, float _targetHeight)
// {

// 	if (_inPoints == null || _inPoints.length == 0) return null;
// 	float minX = _inPoints[0][0].x;

// 	float maxX = _inPoints[0][0].x;

// 	//  float minY = _inPoints[0][0].y;
// 	//  float maxY = _inPoints[0][0].y;


// 	//find min and max of current drawing
// 	for (int i = 0; i<_inPoints.length; i++) {
// 		if (_inPoints[i] != null) {
// 			for (int j = 1; j<_inPoints[i].length; j++) {
// 				if (minX >  _inPoints[i][j].x) minX =  _inPoints[i][j].x;

// 				if (maxX <  _inPoints[i][j].x) maxX =  _inPoints[i][j].x;

// 		//	if (minY >  _inPoints[i][j].y) minY =  _inPoints[i][j].y;
// 		//	if (maxY <  _inPoints[i][j].y) maxY =  _inPoints[i][j].y;
// 	}
// }
// }
// 	println("minX " + minX + " maxX " + maxX);// + " minY " + minY + " maxY " + maxY);

// 	//remap them to targets
// 	for (int i = 0; i<_inPoints.length; i++) {
// 		if (_inPoints[i] != null) {
// 			for (int j = 0; j<_inPoints[i].length; j++) {

// 				_inPoints[i][j].x = map(_inPoints[i][j].x, minX, maxX, 0, _targetWidth);
// 				_inPoints[i][j].y = map(_inPoints[i][j].y, minX, maxX, 0, _targetHeight);
// 			}
// 		}
// 	}

// 	return _inPoints;
// }

