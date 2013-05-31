import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import geomerative.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Drawbot_Controller_Old extends PApplet {





//library vars
ControlP5 cp5;
Serial arduinoSerial;
RShape svgShape;

//RPoint[][] pointPaths;

//setings
float drawScale = 9.7656f;
// 3,906 steps across board / 400 pixels in preview

//data
ArrayList segments;

//interface
Rectangle previewRect;
Rectangle listRect;
Rectangle controlRect;
Rectangle consoleRect;

int penUpAngle = 60;
int penDownAngle = 45;
int desiredSpeed = 150;
ListBox instructionListBox;

//state
float timeSliderValue;
int currentSegment;
boolean flagSendNext;
PVector currentLoc;

//components
BotController botController;


Textarea consoleTextArea;
Println console;

public void setup() {
  //init libraries
  cp5 = new ControlP5(this);
  RG.init(this);
  arduinoSerial = new Serial(this, Serial.list()[0], 9600);
  arduinoSerial.bufferUntil('\n');

  //set up interface
  size(800, 600);
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

  // cp5.addButton("scalePointPaths")
  //   .setPosition(controlRect.x + 110, controlRect.y + 40)
  //     .setSize(100, 20)
  //       ;

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


  consoleTextArea = cp5.addTextarea("txt")
  .setPosition(consoleRect.x, consoleRect.y)
  .setSize((int)consoleRect.w, (int)consoleRect.h)
  .setLineHeight(14)
  .setColor(color(200))
  .setColorBackground(color(0, 100))
  .setColorForeground(color(255, 100));


  console = cp5.addConsole(consoleTextArea);//

  instructionListBox.captionLabel().set("Bot Instructions");
  instructionListBox.captionLabel().style().marginTop = 3;
  instructionListBox.valueLabel().style().marginTop = 3;



  //initialize state
  timeSliderValue = 1.0f;
  segments = new ArrayList();
  currentSegment = 0;
  flagSendNext = false;
  currentLoc = new PVector(0.0f, 0.0f);

  botController = new BotController();
  parseFile("bns.test.svg");
}

//////////////////////////////////////////////////////
// Button Handlers

public void openSVG(int theValue) {
  selectInput("Select a file to process:", "svgSelection");
}

public void openBOT(int theValue) {
  selectInput("Select a file to load:", "botFileSelection");
}

public void scalePointPaths(int theValue) {
  //  pointPaths = scalePointPaths(pointPaths, 500, 500);
}

public void startBot(int theValue) {
  botController.start();
}

//////////////////////////////////////////////////////
// Vector Data

public void svgSelection(File selection) {
  if (selection == null) {
    println("File not Selected.");
    return;
  } 
  println("User Selected: " + selection.getAbsolutePath());
  parseFile(selection.getAbsolutePath());
}

public void botFileSelection(File selection) {
  if (selection == null) {
    println("File not Selected.");
    return;
  } 
  println("User Selected: " + selection.getAbsolutePath());
  botController.instructions = new ArrayList();
  try {
    BufferedReader reader;
    reader = createReader(selection.getAbsolutePath());  
    String fileLine;
    while ( (fileLine = reader.readLine()) != null) {
      if (!fileLine.equals("")){
        botController.instructions.add(fileLine);
      }
    }
  }
  catch(IOException e){
    println("could not read the .bot file");
  }

  instructionListBox.clear();
  for (int i=0;i<botController.instructions.size();i++) {
    ListBoxItem lbi = instructionListBox.addItem((String)botController.instructions.get(i), i);
      // lbi.setColorBackground(0xffff0000);
    }
  }

  public void parseFile(String file) {
    println("Parse File: "+ file);
  //Read Data
  svgShape = RG.loadShape(file);
  if (svgShape == null) {
    println("Failed to read SVG data");
    return;
  }

  //Polygonize
  RG.setPolygonizer(RG.ADAPTATIVE);
  // RG.setPolygonizerAngle(.04);
  RPoint[][] pointPaths;
  pointPaths = svgShape.getPointsInPaths();
  if (pointPaths == null || pointPaths.length == 0) {
    println("Failed to polygonize vector data");
    return;
  }

  //Build Segments
  segments = new ArrayList();

  for (int i = 0; i<pointPaths.length; i++) {
    if (pointPaths[i] != null && pointPaths.length > 0) {
      segments.add(new Segment("move", pointPaths[i][0].x, pointPaths[i][0].y));
      for (int j = 1; j<pointPaths[i].length; j++) {
        segments.add(new Segment("draw", pointPaths[i][j].x, pointPaths[i][j].y));
      }
    }
  }

  botController.loadSegments(segments);
}

//////////////////////////////////////////////////////
// Draw Interface


public void draw() {
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




public void serialEvent(Serial myPort) {
  println("serial event");
  botController.serialEvent(myPort);
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

  public void loadSegments(ArrayList _segments) {
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

  public String penInstruction(int _a) {
    return "1,"+_a+",";
  }

  public String moveInstruction(float _x, float _y) {
    int x = (int)(_x * drawScale);
    int y = (int)(_y * drawScale);
    return "2,"+x+","+y+",";
  }

  public String resetInstruction() {
    return "3,";
  }

  public String speedInstruction(int _s) {
    return "8,"+_s+",";
  }

  public void step() {
    if (flagSendNext) {
      flagSendNext = false;
      sendNext();
    }
  }
  
  public void start() {
    currentInstruction = 0;
    flagSendNext = true;
  }
  
  
  public void sendNext() {
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

  public void serialEvent(Serial port) {
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


public void keyPressed() {
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Drawbot_Controller_Old" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
