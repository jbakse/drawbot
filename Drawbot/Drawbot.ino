#include <AccelStepper.h>
#include <AFMotor.h>
#include <Servo.h>


//motors
AF_Stepper xMotor(200, 2);
AF_Stepper yMotor(200, 1);
Servo penServo;

//state
int mySpeed;
int stepType = MICROSTEP; //SINGLE DOUBLE INTERLEAVE MICROSTEP

void setup()
{
  Serial.begin(9600);
  penServo.attach(9);
  Serial.println("wake");
  mySpeed = 100;
}

void loop()
{


  readSerial();
}

void readSerial()
{
  /*###################################*/

  //Serial stuff


  while (Serial.available() > 0)
  {

    int command  = Serial.parseInt();

    if (command == 1) //pen
    {
      int a = Serial.parseInt();
      pen(a);
    }

    else if (command == 2) //move
    {
      int x = Serial.parseInt();
      int y = Serial.parseInt();
      int speed = Serial.parseInt();
      setSpeed(speed);
      moveSteps(x, y);
    }

    else if (command == 3) //reset
    {
      // Serial.println("done");
    }

    else if (command == 8) //speed
    {
      int newSpeed = Serial.parseInt();
      setSpeed(newSpeed);
    }

    while (Serial.available() && Serial.read() != '\n')
    {
      //rest of bytes are garbage
    }
    Serial.println("done");

  }
}

void pen(int angle)
{
  penServo.write(angle);
  delay(25);
  // Serial.println("done");
}

void setSpeed(int val)
{
  mySpeed = constrain(val, 10, 1000);
  // Serial.println("done");
}

void moveSteps(long xSteps, long ySteps)
{
  xMotor.setSpeed(mySpeed);
  yMotor.setSpeed(mySpeed);

  int xDirection = FORWARD;
  if (xSteps < 0) xDirection = BACKWARD;

  int yDirection = BACKWARD; //y is wired backwards
  if (ySteps < 0) yDirection = FORWARD;


  int xStepped = 0;
  int yStepped = 0;

  if (xSteps != 0 && ySteps != 0)
  {
    float yDelta = abs(ySteps) / (float)abs(xSteps);
    float yAccumulator = 0;
    for (int x = 0; x < abs(xSteps); x++)
    {
      xMotor.step(1, xDirection, stepType);
      xStepped++;
      yAccumulator += yDelta;
      while (yAccumulator > 1)
      {
        yMotor.step(1, yDirection, stepType);
        yStepped++;
        yAccumulator -= 1;
      }
    }
    while (yStepped < abs(ySteps))
    {
      yMotor.step(1, yDirection, stepType);
      yStepped++;
    }


  }
  else if (xSteps == 0)
  {
    for (int y = 0; y < abs(ySteps); y++)
    {
      yMotor.step(1, yDirection, stepType);
      yStepped++;
    }
  }
  else if (ySteps == 0)
  {
    for (int x = 0; x < abs(xSteps); x++)
    {
      xMotor.step(1, xDirection, stepType);
      xStepped++;
    }
  }

  if (abs(xSteps) != xStepped || abs(ySteps) != yStepped) {
    Serial.println("WARNING WARNING WARNING WARNING WARNING");
    Serial.print(xSteps);
    Serial.print(",");
    Serial.print(ySteps);
    Serial.print(" ");
    Serial.print(xStepped);
    Serial.print(",");
    Serial.println(yStepped);
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
  // Serial.println("done");
}











