import controlP5.*;
import geomerative.*;
import processing.serial.*;
import java.io.File;

Settings settings;
User_Interface userInterface;
// Bot_Driver botDriver;
Parser parser;
Visualizer visualizer;
Instruction_Set instructionSet;


void setup() {
	RG.init(this);
	cp5 = new ControlP5(this);
	
	size(800, 600);
	
	//initialize components
	settings = new Settings();
	userInterface = new User_Interface();
	// botDriver = new Bot_Driver();
	parser = new Parser();
	visualizer = new Visualizer();

	//instructionSet = parser.parseSVG("default.svg");
}

void draw() {
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

void svgSelection(File selection) {
	if (!checkSelectionMade(selection)) return;
	instructionSet = parser.parseSVG(selection.getAbsolutePath());
}

public void openBOT(int theValue) {
	selectInput("Select a file to load:", "botFileSelection");
}

void botFileSelection(File selection) {
	if (!checkSelectionMade(selection)) return;
	instructionSet = parser.parseBOT(selection.getAbsolutePath());
}

boolean checkSelectionMade(File selection){
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