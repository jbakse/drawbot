import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import geomerative.*; 
import processing.serial.*; 
import java.io.File; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Drawbot_Controller extends PApplet {






Settings settings;
User_Interface userInterface;
// Bot_Driver botDriver;
Parser parser;
Visualizer visualizer;
Instruction_Set instructionSet;


public void setup() {
	RG.init(this);
	cp5 = new ControlP5(this);
	
	size(800, 600);
	
	//initialize components
	settings = new Settings();
	userInterface = new User_Interface();
	// botDriver = new Bot_Driver();
	parser = new Parser();
	visualizer = new Visualizer();

	println(dataPath("default.svg"));
	instructionSet = parser.parseSVG(dataPath("default.svg"));
	println("Instruction Set");
	println(instructionSet);
	
}

public void draw() {
	background(50);
	fill(255);
	userInterface.draw();
	// botDriver.step();
}


//////////////////////////////////////////////////////
// Button Handlers

public void openSVG(int theValue) {
	selectInput("Select a file to process:", "svgSelection");
}

public void svgSelection(File selection) {
	if (!checkSelectionMade(selection)) return;
	instructionSet = parser.parseSVG(selection.getAbsolutePath());
}

public void openBOT(int theValue) {
	selectInput("Select a file to load:", "botFileSelection");
}

public void botFileSelection(File selection) {
	if (!checkSelectionMade(selection)) return;
	instructionSet = parser.parseBOT(selection.getAbsolutePath());
}

public boolean checkSelectionMade(File selection){
	if (selection == null) {
		println("File not Selected.");
		return false;
	} 
	println("User Selected: " + selection.getAbsolutePath());
	return true;
}

public void startBot(int theValue) {
	// botDriver.start();
}
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
class Instruction_Set {
	ArrayList instructions;

	Instruction_Set() {
		instructions = new ArrayList();
	}

	public void appendPen(int _pos){
		instructions.add(new Instruction("pen", new int[]{_pos}));
	}

	public void appendPenUp(){
		instructions.add(new Instruction("pen", new int[]{settings.penUpAngle}));
	}

	public void appendPenDown(){
		instructions.add(new Instruction("pen", new int[]{settings.penDownAngle}));
	}

	public void appendMove(int _x, int _y){
		instructions.add(new Instruction("move", new int[]{_x, _y}));
	}

	public void appendSpeed(int _speed){
		instructions.add(new Instruction("speed", new int[]{_speed}));
	}

	public String toString() {
		String output = "";
		for (int i = 0; i < instructions.size(); i++){
			output += instructions.get(i).toString() + "\n";
		}
		return output;
	}

}

class Instruction {
	String name;
	int code;
	int params[];
	
	Instruction(String _name, int _params[]) {
		name = _name;
		if (_name.equals("pen")){
			code = 1;
		}
		else if (_name.equals("move")){
			code = 2;
		}
		else if(_name.equals("reset")){
			code = 3;
		}
		else if(_name.equals("speed")){
			code = 8;
		}
		params = _params;
	}

	public String toString() {
		String output = name + " (" + code + "): ";
		for (int i = 0; i < params.length; i++){
			output += params[i] + ", ";
		}
		return output;
	}
}
RShape svgShape;
ArrayList segments;

class Parser {
	Parser() {
		segments = new ArrayList();
	}
	public Instruction_Set parseBOT(String file) {
		return new Instruction_Set();
		// botController.instructions = new ArrayList();
		// try {
		// 	BufferedReader reader;
		// 	reader = createReader(file);  
		// 	String fileLine;
		// 	while ( (fileLine = reader.readLine()) != null) {
		// 		if (!fileLine.equals("")){
		// 			botController.instructions.add(fileLine);
		// 		}
		// 	}
		// }
		// catch(IOException e){
		// 	println("could not read the .bot file");
		// }

		// instructionListBox.clear();
		// for (int i=0;i<botController.instructions.size();i++) {
		// 	ListBoxItem lbi = instructionListBox.addItem((String)botController.instructions.get(i), i);
		// 	// lbi.setColorBackground(0xffff0000);
		// }
	}

	public Instruction_Set parseSVG(String file) {
		println("Parse File: "+ file);
		
		if (!checkPath(file)) {
			println("File doesn't exist! "+file);
			return null;
		}

		//Read Data
		svgShape = RG.loadShape(file);
		if (svgShape == null) {
			println("Failed to read SVG data");
			return null;
		}

		//Polygonize
		RG.setPolygonizer(RG.ADAPTATIVE);
		RPoint[][] pointPaths;
		pointPaths = svgShape.getPointsInPaths();
		if (pointPaths == null || pointPaths.length == 0) {
			println("Failed to polygonize vector data");
			return null;
		}

		//Build Instructions
		float posX = 0;
		float posY = 0;

		boolean penDown = false;

		Instruction_Set instructions = new Instruction_Set();


		for (int i = 0; i < pointPaths.length; i++) {
			if (pointPaths[i] != null && pointPaths.length > 0) {
				for (int j = 0; j<pointPaths[i].length; j++) {
					if (j == 0){
						instructions.appendPenUp();
					}
					if (j == 1){
						instructions.appendPenDown();
					}
					int x = (int)((pointPaths[i][j].x * settings.xStepsPerPoint) - posX);
					int y = (int)((pointPaths[i][j].y * settings.yStepsPerPoint) - posY);
					instructions.appendMove(x, y);
					posX += x;
					posY += y;
				}
			}
		}

		return instructions;

		// botController.loadSegments(segments);
	}

	public boolean checkPath(String path){
		File f = new File(path);
		return f.exists(); 
	}
}



class Settings {
	public float drawScale = 9.7656f;
	// 3,906 steps across board / 400 pixels in preview
	public int penUpAngle = 75;
	public int penDownAngle = 82;
	public int desiredSpeed = 50;
	public float xStepsPerPoint = 2.77f;// 200/72;
	public float yStepsPerPoint = 2.77f;
	
	Settings() {
	
	}
}
ControlP5 cp5;

Rectangle previewRect;
Rectangle listRect;
Rectangle controlRect;
Rectangle consoleRect;

ListBox instructionListBox;
Textarea consoleTextArea;
Println console;

float timeSliderValue;

class User_Interface {
	User_Interface() {
		previewRect = new Rectangle(10, 10, 400, 200);
		listRect = new Rectangle(420, 25, 370, 380);
		controlRect = new Rectangle(10, 220, 400, 370);
		consoleRect = new Rectangle(420, 415, 370, 175);

		cp5.addSlider("timeSliderValue")
		.setPosition(controlRect.x, controlRect.y)
		.setWidth((int)controlRect.w)
		.setRange(0, 1)
		.setSliderMode(Slider.FLEXIBLE)
		;

		cp5.getController("timeSliderValue").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
		cp5.getController("timeSliderValue").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

		cp5.addButton("openSVG")
		.setPosition(controlRect.x, controlRect.y + 40)
		.setSize(100, 20)
		;

		cp5.addButton("openBOT")
		.setPosition(controlRect.x+110, controlRect.y + 40)
		.setSize(100, 20)
		;

		cp5.addButton("startBot")
		.setPosition(controlRect.x + 220, controlRect.y + 40)
		.setSize(100, 20)
		;

		instructionListBox = cp5.addListBox("instructionListBox")
		.setPosition(listRect.x, listRect.y)
		.setSize((int)listRect.w, (int)listRect.h)
		.setItemHeight(20)
		.setBarHeight(15)
		.setColorBackground(color(25))
		.setColorActive(color(0))
		.setColorForeground(color(255, 100, 0))
		.setScrollbarWidth(20)
		;
		instructionListBox.captionLabel().set("Bot Instructions");
		instructionListBox.captionLabel().style().marginTop = 3;
		instructionListBox.valueLabel().style().marginTop = 3;


		consoleTextArea = cp5.addTextarea("txt")
		.setPosition(consoleRect.x, consoleRect.y)
		.setSize((int)consoleRect.w, (int)consoleRect.h)
		.setLineHeight(14)
		.setColor(color(200))
		.setColorBackground(color(0, 100))
		.setColorForeground(color(255, 100));
		
		console = cp5.addConsole(consoleTextArea);



		timeSliderValue = 1.0f;

	}

	public void draw(){
		
	}
}
class Rectangle {
  float x;
  float y;
  float w;
  float h;
  Rectangle(float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }
}
PVector currentLoc;

class Visualizer {
	 Visualizer() {
	 	currentLoc = new PVector(0.0f, 0.0f);
	 }

	 public void draw(){
		//draw vector data
		// pushMatrix();
		// {
		// translate(10, 10);
		// noFill();
		// PVector pos = new PVector(0, 0);
		// for (int i = 0; i < segments.size() * timeSliderValue; i++) {
		// 	Segment seg = (Segment)segments.get(i);
		// 	if (seg.type == "move") {
		// 	stroke(200, 100, 100);
		// 	}
		// 	else if (seg.type == "draw") {
		// 	stroke(100, 200, 100);
		// 	}
		// 	line(pos.x, pos.y, seg.x, seg.y);
		// 	pos.x = seg.x;
		// 	pos.y = seg.y;
		// }
		// }
		// popMatrix();
	 }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Drawbot_Controller" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
