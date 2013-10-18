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
int stepType = DOUBLE; //SINGLE DOUBLE INTERLEAVE MICROSTEP

#include <Servo.h>

Servo penServo;
int xStopPin = 12;
int yStopPin = 11;
//state


void setup()
{
  Serial.begin(9600);
  AFMS.begin();   //motor shield 2
  penServo.attach(9);
  pen(160);

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
  penServo.write(angle);
  delay(25);
}

void setSpeed(int _speed)
{
  int speed = constrain(_speed, 10, 1000);
  setXSpeed(speed);
  setYSpeed(speed);
}

void moveSteps(long xSteps, long ySteps)
{


  int xDirection = FORWARD;
  if (xSteps < 0) xDirection = BACKWARD;

  int yDirection = BACKWARD; //y is wired backwards
  if (ySteps < 0) yDirection = FORWARD;


  int xStepped = 0;
  int yStepped = 0;

  if (xSteps != 0 && ySteps != 0) {
    float yDelta = abs(ySteps) / (float)abs(xSteps);
    float yAccumulator = 0;
    for (int x = 0; x < abs(xSteps); x++) {
      stepX(1, xDirection, stepType);
      xStepped++;
      yAccumulator += yDelta;
      while (yAccumulator > 1) {
        stepY(1, yDirection, stepType);
        yStepped++;
        yAccumulator -= 1;
      }
    }
    while (yStepped < abs(ySteps)) {
      stepY(1, yDirection, stepType);
      yStepped++;
    }
  }
  else if (xSteps == 0) {
    for (int y = 0; y < abs(ySteps); y++) {
      stepY(1, yDirection, stepType);
      yStepped++;
    }
  }
  else if (ySteps == 0) {
    for (int x = 0; x < abs(xSteps); x++) {
      stepX(1, xDirection, stepType);
      xStepped++;
    }
  }

}















