import controlP5.*;
import geomerative.*;
import processing.serial.*;

import java.io.File;

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
	userInterface = new User_Interface();
	botDriver = new Bot_Driver(this);
	parser = new Parser();
	visualizer = new Visualizer();

	instructionSet = parser.parseSVG(dataPath("default.svg"));
	displayInstructions(instructionSet);

}

void draw() {

	background(50);
	fill(255);
	userInterface.draw();
	visualizer.draw(instructionSet, (int)(instructionSet.instructions.size() * timeSliderValue));
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
	displayInstructions(instructionSet);
}

public void openBOT(int theValue) {
	selectInput("Select a file to load:", "botFileSelection");
}

void botFileSelection(File selection) {
	if (!checkSelectionMade(selection)) return;
	instructionSet = parser.parseBOT(selection.getAbsolutePath());
	displayInstructions(instructionSet);
}

boolean checkSelectionMade(File selection){
	if (selection == null) {
		println("File not Selected.");
		return false;
	} 
	println("User Selected: " + selection.getAbsolutePath());
	return true;
}

public void startBot(int theValue){
	botDriver.start();
}

/////////////////////////////////////////////////////


void displayInstructions(Instruction_Set instructionSet){
	instructionListBox.clear();
	for (int i=0; i < instructionSet.instructions.size(); i++) {
		ListBoxItem lbi = instructionListBox.addItem(((Instruction)instructionSet.instructions.get(i)).toString(), i);
		// lbi.setColorBackground(0xffff0000);
	}
}



void serialEvent(Serial port) {
	botDriver.serialEvent(port);
}