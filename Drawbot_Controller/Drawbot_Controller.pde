import controlP5.*;
import geomerative.*;
import processing.serial.*;

import java.io.File;

// components
Settings settings;
User_Interface userInterface;
Bot_Driver botDriver;
Parser parser;
Visualizer visualizer;

// state
Instruction_Set instructionSet;


void setup()
{
    RG.init(this);
    cp5 = new ControlP5(this);

    size(800, 600);

    // initialize components
    settings = new Settings();
    userInterface = new User_Interface();
    botDriver = new Bot_Driver(this);
    parser = new Parser();
    visualizer = new Visualizer();

    // load initial file
    svgSelection(new File(dataPath("hello.svg")));
}

synchronized void draw()
{
    background(50);
    userInterface.draw();
    visualizer.draw(instructionSet, (int)(instructionSet.instructions.size() * timeSliderValue));
}



//////////////////////////////////////////////////////
// Button Handlers

synchronized public void openSVG(int theValue)
{
    selectInput("Select a file to process:", "svgSelection");
}

synchronized void svgSelection(File selection)
{
    if (!checkSelectionMade(selection)) return;
    instructionSet = parser.parseSVG2(selection.getAbsolutePath());
    displayInstructions(instructionSet);
}


synchronized public void openBOT(int theValue)
{
    selectInput("Select a file to load:", "botFileSelection");
}

synchronized void botFileSelection(File selection)
{
    if (!checkSelectionMade(selection)) return;
    instructionSet = parser.parseBOT(selection.getAbsolutePath());
    displayInstructions(instructionSet);
}


boolean checkSelectionMade(File selection)
{
    if (selection == null)
    {
        println("File not Selected.");
        return false;
    }
    println("User Selected: " + selection.getAbsolutePath());
    return true;
}

public void startBot(int theValue)
{
    botDriver.start();
}

public void pauseBot(int theValue)
{
	botDriver.pause();
}

public void resumeBot(int theValue)
{
	botDriver.resume();
}

//////////////////////////////////////////////////////
// UI


synchronized void displayInstructions(Instruction_Set instructionSet)
{
    instructionListBox.clear();
    for (int i = 0; i < instructionSet.instructions.size(); i++)
    {
        ListBoxItem lbi = instructionListBox.addItem(((Instruction)instructionSet.instructions.get(i)).toString(), i);
    }
}

//////////////////////////////////////////////////////
// Serial

void serialEvent(Serial p)
{
    if (botDriver != null) {
        botDriver.serialEvent(p);
    }
}
