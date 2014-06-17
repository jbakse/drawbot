// // // // //  ADAFRUIT MOTOR SHIELD 1 // // // // //

// #include <AccelStepper.h>
// #include <AFMotor.h>
// #include <Servo.h>

// void stepX(int steps, int direction, int type)
// {
//  xMotor.step(steps, xDirection, stepType);
// }
// void stepY(int steps, int direction, int type)
// {
//  yMotor.step(steps, xDirection, stepType);
// }
// void setXSpeed(int speed)
// {
//  xMotor.setSpeed(speed);
// }
// void setYSpeed(int speed)
// {
//  yMotor.setSpeed(speed);
// }

// AF_Stepper xMotor(200, 2);
// AF_Stepper yMotor(200, 1);


//void releaseMotors()
//{
//  xMotor.release();
//  yMotor.release();
//}

// // // // //  ADAFRUIT MOTOR SHIELD VERSION 2 // // // // //

#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield();

Adafruit_StepperMotor *xMotor = AFMS.getStepper(200, 2);
Adafruit_StepperMotor *yMotor = AFMS.getStepper(200, 1);

void stepX(int steps, int d, int type)
{
  xMotor->step(steps, d, type);
}
void stepY(int steps, int d, int type)
{
//  int d2 = FORWARD;
//  if (d == FORWARD) d2 = BACKWARD;
  yMotor->step(steps, d, type);
}
void setXSpeed(int speed)
{
  xMotor->setSpeed(speed);
}
void setYSpeed(int speed)
{
  yMotor->setSpeed(speed);
}

void releaseMotors()
{
  xMotor->release();
  yMotor->release();
}


//config
int stepType = INTERLEAVE; //SINGLE DOUBLE (INTERLEAVE) MICROSTEP

#include <Servo.h>

Servo penServo;
int xStopPin = 12;
int yStopPin = 11;
//state


void setup()
{
  Serial.begin(115200);
  AFMS.begin();   //motor shield 2
  penServo.attach(9);
  pen(60);

  pinMode(xStopPin, INPUT);           
  digitalWrite(xStopPin, HIGH); //pull up
  pinMode(yStopPin, INPUT);
  digitalWrite(yStopPin, HIGH); //pull up

  Serial.println("wake");
  //mySpeed = 100;
}

void loop()
{
  readSerial();
}



void readSerial()
{
  /*###################################*/

  //Serial stuff


  while (Serial.available() > 0) {

    int command  = Serial.parseInt();

    if (command == 1) { //pen
      int a = Serial.parseInt();
      pen(a);
    }
    else if (command == 2) { //move
      int x = Serial.parseInt();
      int y = Serial.parseInt();
      int speed = Serial.parseInt();
      setSpeed(speed);
      moveSteps(x, y);
      //Serial.println(micros());
      //myStepXY(x, y, speed, SINGLE);
      //Serial.println(micros());
    }

    else if (command == 3) { //home
      homeXY();
      // while (digitalRead(xStopPin) == 0) {
      // 	stepX(1, BACKWARD, stepType); 
      // }
      // todo: this
    }
    else if (command == 4) { //release
      releaseMotors();
    }

    else if (command == 8) { //speed
      int newSpeed = Serial.parseInt();
      setSpeed(newSpeed);
    }

    while (Serial.available() && Serial.read() != '\n') {
      //rest of bytes are garbage. garbage!
    }
    Serial.println("done");

  }
}


void homeXY()
{
  setSpeed(200);
  boolean up = true;
  boolean left = true;

  while (up || left) {
    if (up) stepY(1, FORWARD, stepType); // Y is wired backwards
    if (left) stepX(1, BACKWARD, stepType); 

    if (digitalRead(yStopPin) == 0) up = false;
    if (digitalRead(xStopPin) == 0) left = false; 
  }

}

void pen(int angle)
{
  delay(200);
  penServo.write(angle);
  delay(200);
}

int maxSpeed;

void setSpeed(int _speed)
{
  maxSpeed = constrain(_speed, 10, 1000);
  setXSpeed(maxSpeed);
  setYSpeed(maxSpeed);
}

void moveSteps(long xSteps, long ySteps)
{

  boolean oneStepX = false;
  boolean oneStepY = false;
  if (abs(xSteps) > abs(ySteps)) {
    oneStepY = true;
  }
  else{
    oneStepX = true;

  }

  int xDirection = FORWARD;
  if (xSteps < 0) xDirection = BACKWARD; //y is backwards?

  int yDirection = BACKWARD; 
  if (ySteps < 0) yDirection = FORWARD;


  int xStepped = 0;
  int yStepped = 0;

  if (xSteps != 0 && ySteps != 0) {
    float yDelta = abs(ySteps) / (float)abs(xSteps);
    float yAccumulator = 0;
    for (int x = 0; x < abs(xSteps); x++) {

      if (oneStepX) {
        xMotor->onestep(xDirection, stepType);
      } 
      else {
        stepX(1, xDirection, stepType);
      }

      xStepped++;
      yAccumulator += yDelta;
      while (yAccumulator > 1) {
        if (oneStepY){
          yMotor->onestep(yDirection, stepType);
        }
        else{
          stepY(1, yDirection, stepType);
        }
        yStepped++;
        yAccumulator -= 1;
      }
    }
    while (yStepped < abs(ySteps)) {
      if (oneStepY){
        yMotor->onestep(yDirection, stepType);
      }
      else{
        stepY(1, yDirection, stepType);
      }      
      yStepped++;
    }
  }
  else if (xSteps == 0) {
    for (int y = 0; y < abs(ySteps); y++) {
      stepY(1, yDirection, stepType);
      //yMotor->onestep(yDirection, stepType);
      yStepped++;
    }
  }
  else if (ySteps == 0) {
    for (int x = 0; x < abs(xSteps); x++) {
      stepX(1, xDirection, stepType);
      //xMotor->onestep(xDirection, stepType);
      xStepped++;
    }
  }

}




void myStepXY(int stepsX, int stepsY, int rpm, int style){
  int xDir = FORWARD;
  if (stepsX < 0) xDir = BACKWARD;

  int yDir = BACKWARD;
  if (stepsY < 0) yDir = FORWARD;

  stepsX = abs(stepsX);
  stepsY = abs(stepsY);

  unsigned long xRPM = 0;
  unsigned long yRPM = 0;

  if (stepsX > stepsY) {
    xRPM = rpm;
    yRPM = (rpm * (unsigned long)stepsY) / stepsX;
  } 
  else {
    yRPM = rpm;
    xRPM = (rpm * (unsigned long)stepsX) / stepsY;
  }


  unsigned long xMicrosPerStep;
  unsigned long yMicrosPerStep;

  if (stepsX == 0) {
    xMicrosPerStep = 1000000 * 60 * 10; 
  }
  else{
    xMicrosPerStep = ((60*1000000)/xRPM)/200;
  }

  if (stepsY == 0) {
    yMicrosPerStep = 1000000 * 60 * 10; 
  } 
  else {
    yMicrosPerStep = ((60*1000000)/yRPM)/200;
  }

  //  Serial.print("RPM: ");
  //  Serial.print(xRPM);
  //  Serial.print(",");
  //  Serial.print(yRPM);
  //
  //  Serial.print(" MicrosPerStep: ");
  //  Serial.print(xMicrosPerStep);
  //  Serial.print(",");
  //  Serial.print(yMicrosPerStep);
  //
  //  Serial.print(" Steps: ");
  //  Serial.print(stepsX);
  //  Serial.print(",");
  //  Serial.print(stepsY);
  //
  //  Serial.print(" Total: ");
  //  Serial.print(xMicrosPerStep * stepsX);
  //  Serial.print(",");
  //  Serial.println(yMicrosPerStep * stepsY);

  int xStep = 0;
  int yStep = 0;
  unsigned long startTime = micros();


  while(xStep < stepsX || yStep < stepsY) {

    if (xStep < stepsX && micros() - startTime > (xStep + 1) * xMicrosPerStep) {
      xMotor->onestep(xDir, style);
      xStep++;
    }
    if (yStep < stepsY &&  micros() - startTime > (yStep + 1) * yMicrosPerStep) {
      yMotor->onestep(yDir, style);
      yStep++;
    }
  }
  //  Serial.print(" Steps Taken: ");
  //  Serial.print(xStep);
  //  Serial.print(",");
  //  Serial.println(yStep);



  //  
  //  unsigned long waits = 0;
  //  
  //  unsigned long startTime = micros();
  //  for (int i = 0; i < steps; i++) {
  //    while(micros() - startTime < i * microsPerStep){
  //      waits++;
  //    }
  //    yMotor->onestep(dir, style);
  //  }
  //Serial.println(waits);
}














