#include <AccelStepper.h>
#include <AFMotor.h>
#include <Servo.h> 


//motors
AF_Stepper motor1(200, 2);
AF_Stepper motor2(200, 1);
Servo servo1;

//MOTOR STUFFS
void forwardstep1() {  
  motor1.onestep(FORWARD, DOUBLE);
}
void backwardstep1() {  
  motor1.onestep(BACKWARD, DOUBLE);
}
// wrappers for the second motor!
void forwardstep2() {  
  motor2.onestep(BACKWARD, SINGLE);
}
void backwardstep2() {  
  motor2.onestep(FORWARD, SINGLE);
}

// Motor shield has two motor ports, now we'll wrap them in an AccelStepper object
AccelStepper stepper1(forwardstep1, backwardstep1);
AccelStepper stepper2(forwardstep2, backwardstep2);

boolean moving=false;
boolean useAcceleration=false;

int maxSpeed;

void setup() {
  
  maxSpeed = 100.0;
  
  stepper1.setSpeed(200.0);
  stepper2.setSpeed(200.0);

  stepper1.setMaxSpeed(300.0);
  stepper2.setMaxSpeed(300.0);

  stepper1.setAcceleration(200.0);
  stepper2.setAcceleration(200.0);

  // set up Serial library at 9600 bps
  Serial.begin(9600);

  servo1.attach(9);

  stepper1.setCurrentPosition(0);
  stepper2.setCurrentPosition(0);


  Serial.println("wake");

}

void loop() {

  /*###################################*/

  //Motor stuff
  if(useAcceleration){
    stepper1.run();
    stepper2.run();
  }
  else{
    stepper1.runSpeedToPosition();
    stepper2.runSpeedToPosition();
  }


  if (stepper1.distanceToGo() == 0 && stepper2.distanceToGo() == 0 && moving == true){
    moving = false;
    Serial.println("done");
  }

  /*###################################*/

  //Serial stuff
 
  int command = 0;
   /*
  int a;
  int x;
  int y;
  int newSpeed;
  */

  while (Serial.available() > 0) {

    command  = Serial.parseInt();

    if(command==1)
    {
      int a = Serial.parseInt();
      pen(a);
    }

    if(command==2)
    {
      int x = Serial.parseInt();
      int y = Serial.parseInt();
       moveSteps(x, y);
    }
    
    if(command == 3){
      Serial.println("done");
    }
  
    if(command==8)
    {
      int newSpeed = Serial.parseInt();
      setMaxSpeed(newSpeed);
    }

    while (Serial.available() && Serial.read() != '\n') {
      //rest of bytes are garbage
    }


  }
}

void pen(int angle)
{
  servo1.write(angle);
  delay(50);
  Serial.println("done");
}

void setMaxSpeed(int val)
{
  if(val < 10){
    val = 10;
  }
  if(val > 1000){
    val = 1000;
  }
  maxSpeed = val;
  Serial.println("done");
}

void moveSteps(long xSteps, long ySteps)
{
  moving = true;

  stepper1.setCurrentPosition(0);
  stepper2.setCurrentPosition(0);

  //set speeds to accomodate for
  //*
  //int maxSpeed = 250.0;

  float xSpeed;
  float ySpeed;

  //if (xSteps == 0) xSteps = 1;
  //if (ySteps == 0) ySteps = 1;

  if (xSteps == 0 && ySteps == 0) {
    stepper1.moveTo(0);
    stepper2.moveTo(0);
    return; 
  }
  
  if (abs(xSteps) > abs(ySteps)){
    xSpeed = maxSpeed;
    ySpeed = maxSpeed * abs(ySteps) / abs(xSteps);
    if (ySpeed < 10) ySpeed = 10;

  }
  else {
    ySpeed = maxSpeed;
    xSpeed = maxSpeed * abs(xSteps) / abs(ySteps);
    if (xSpeed < 10) xSpeed = 10;
  }

  if(useAcceleration){
    stepper1.setMaxSpeed(xSpeed);
    stepper2.setMaxSpeed(ySpeed);
    
    stepper1.setAcceleration(xSpeed+10);
    stepper2.setAcceleration(ySpeed+10);
    
  }else{
    if (xSteps < 0){
      xSpeed = -xSpeed;
    }
    if (ySteps < 0){
      ySpeed = -ySpeed;
    }
  
    stepper1.setSpeed(xSpeed);
    stepper2.setSpeed(ySpeed);
    
  }
  
  stepper1.moveTo(xSteps);
  stepper2.moveTo(ySteps);

}




