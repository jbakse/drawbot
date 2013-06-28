#include <AccelStepper.h>
#include <AFMotor.h>
#include <Servo.h> 


//motors
AF_Stepper xMotor(200, 2);
AF_Stepper yMotor(200, 1);
Servo penServo;

//state
int mySpeed;

void setup() {
  Serial.begin(9600);
  penServo.attach(9);
  Serial.println("wake");
  mySpeed = 100;
}

void loop() {


  readSerial();
}

void readSerial()
{
  /*###################################*/

  //Serial stuff


  while (Serial.available() > 0) {

    int command  = Serial.parseInt();

    if(command==1) //pen
    {
      int a = Serial.parseInt();
      pen(a);
    }

    else if(command==2) //move
    {
      int x = Serial.parseInt();
      int y = Serial.parseInt();
      moveSteps(x, y);
    }

    else if(command == 3) //reset
    {
      Serial.println("done");
    }

    else if(command==8) //speed
    {
      int newSpeed = Serial.parseInt();
      setSpeed(newSpeed);
    }

    while (Serial.available() && Serial.read() != '\n') {
      //rest of bytes are garbage
    }

  }
}

void pen(int angle)
{
  penServo.write(angle);
  delay(50);
  Serial.println("done");
}

void setSpeed(int val)
{
  mySpeed = constrain(val, 10, 1000);
  Serial.println("done");
}

void moveSteps(long xSteps, long ySteps)
{
  xMotor.setSpeed(mySpeed);
  yMotor.setSpeed(mySpeed);

  int xDirection = FORWARD;
  if (xSteps < 0) xDirection = BACKWARD;

  int yDirection = BACKWARD; //y is wired backwards
  if (ySteps < 0) yDirection = FORWARD;

  if (xSteps != 0 && ySteps != 0){
    float yDelta = abs(ySteps) / (float)abs(xSteps);
    float yAccumulator = 0;
    for (int x = 0; x < abs(xSteps); x++){
      xMotor.step(1, xDirection, SINGLE);
      yAccumulator += yDelta;
      while (yAccumulator > 1){
        yMotor.step(1, yDirection, SINGLE);
        yAccumulator -= 1; 
      }
    }
  } 
  else if (xSteps == 0) {
    for (int y = 0; y < abs(ySteps); y++){
      yMotor.step(1, yDirection, SINGLE);
    }
  } 
  else if (ySteps == 0) {
    for (int x = 0; x < abs(xSteps); x++){
      xMotor.step(1, xDirection, SINGLE);
    }
  }


  //  
  //  if (xSteps > 0) {
  //    xMotor.step(xSteps, FORWARD, SINGLE);
  //  }else if(xSteps < 0) {
  //    xMotor.step(-xSteps, BACKWARD, SINGLE);
  //  }  
  //  
  //  
  //   
  //  if (ySteps > 0) {
  //    yMotor.step(ySteps, BACKWARD, SINGLE);
  //  }else if(ySteps < 0) {
  //    yMotor.step(-ySteps, FORWARD, SINGLE);
  //  } 
  //  
  Serial.println("done");
}









