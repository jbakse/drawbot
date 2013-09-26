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


void setup()
{
    RG.init(this);
    cp5 = new ControlP5(this);

    size(800, 600);

    //initialize components
    settings = new Settings();
    userInterface = new User_Interface();
    botDriver = new Bot_Driver(this);
    parser = new Parser();
    visualizer = new Visualizer();

    instructionSet = parser.parseSVG(dataPath("square_test.svg"));
    instructionSet = segmentize(instructionSet);
    instructionSet = accelerize(instructionSet);

    displayInstructions(instructionSet);

}

void draw()
{

    background(50);
    fill(255);
    userInterface.draw();
    visualizer.draw(instructionSet, (int)(instructionSet.instructions.size() * timeSliderValue));
    // botDriver.step();
}


//////////////////////////////////////////////////////
// Button Handlers

public void openSVG(int theValue)
{
    selectInput("Select a file to process:", "svgSelection");
}

void svgSelection(File selection)
{
    if (!checkSelectionMade(selection)) return;
    instructionSet = parser.parseSVG(selection.getAbsolutePath());
    instructionSet = segmentize(instructionSet);
    instructionSet = accelerize(instructionSet);
    displayInstructions(instructionSet);
}

public void openBOT(int theValue)
{
    selectInput("Select a file to load:", "botFileSelection");
}

void botFileSelection(File selection)
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

/////////////////////////////////////////////////////


synchronized void displayInstructions(Instruction_Set instructionSet)
{
    instructionListBox.clear();
    for (int i = 0; i < instructionSet.instructions.size(); i++)
    {
        ListBoxItem lbi = instructionListBox.addItem(((Instruction)instructionSet.instructions.get(i)).toString(), i);
        // lbi.setColorBackground(0xffff0000);
    }
}



void serialEvent(Serial port)
{
    botDriver.serialEvent(port);
}


Instruction_Set segmentize(Instruction_Set _instructionSet)
{
    int SEGMENT_SIZE = 20;
    Instruction_Set _processedInstructions = new Instruction_Set();
    for (Instruction i : _instructionSet.instructions)
    {
        if (i.name.equals("move"))
        {
            int x = i.params[0];
            int y = i.params[1];
            int speed = i.params[2];
            float distance = sqrt(x * x + y * y);
            if (distance > SEGMENT_SIZE)
            {
                int deltaX = (int)((x / distance) * SEGMENT_SIZE);
                int deltaY = (int)((y / distance) * SEGMENT_SIZE);
                int segments = (int)(distance / SEGMENT_SIZE);
                //generate full segments
                for (int segment = 0; segment < segments; segment++)
                {
                    _processedInstructions.instructions.add(new Instruction("move", new int[] {deltaX, deltaY, speed}));
                }
                //generate final, partial segment
                _processedInstructions.instructions.add(new Instruction("move", new int[] {x - (deltaX * segments), y - (deltaY * segments), speed}));
            }
            else
            {
                _processedInstructions.instructions.add(i);
            }
        }
        else
        {
            _processedInstructions.instructions.add(i);
        }
    }
    return _processedInstructions;
}

Instruction_Set accelerize(Instruction_Set _instructionSet)
{
    Instruction_Set _processedInstructions = new Instruction_Set();
    float lastSpeedX = 0;
    float lastSpeedY = 0;
    Instruction lastInstruction = null;
    for (Instruction i : _instructionSet.instructions)
    {
        if (i.name.equals("move"))
        {
            int x = i.params[0];
            int y = i.params[1];
            float distance = sqrt(x * x + y * y);

            float thisSpeedX = x / distance;
            float thisSpeedY = y / distance;
            if (distance < .0001)
            {
                thisSpeedX = 0;
                thisSpeedY = 0;
            }
            println("speeds " + thisSpeedX + " " + thisSpeedY + " " + lastSpeedX + " " + lastSpeedY);
            if (abs(thisSpeedX - lastSpeedX) > .5 || abs(thisSpeedY - lastSpeedY) > .5)
            {
                i.params[2] = 10;
                if (lastInstruction != null)
                {
                    lastInstruction.params[2] = 10;
                }
            }
            _processedInstructions.instructions.add(i);
            lastSpeedX = thisSpeedX;
            lastSpeedY = thisSpeedY;
            lastInstruction = i;
        }
        else
        {
            _processedInstructions.instructions.add(i);
        }
    }

    for (int pass = 0; pass < 10; pass ++)
    {
        int lastSpeed = 10;
        for (int i = 0; i < _instructionSet.instructions.size(); i++)
        {
            Instruction current = _instructionSet.instructions.get(i);
            if (current.name.equals("move"))
            {
                int thisSpeed = current.params[2];
                int avg = (thisSpeed + lastSpeed) / 2;

                if (avg < thisSpeed)
                {
                    current.params[2] = avg;
                }
                lastSpeed = thisSpeed;
            }
        }

        lastSpeed = 10;
        for (int i = _instructionSet.instructions.size() - 1; i >= 0; i--)
        {
            Instruction current = _instructionSet.instructions.get(i);
            if (current.name.equals("move"))
            {
                int thisSpeed = current.params[2];
                int avg = (thisSpeed + lastSpeed) / 2;

                if (avg < thisSpeed)
                {
                    current.params[2] = avg;
                }
                lastSpeed = thisSpeed;
            }
        }

    }

    return _processedInstructions;
}