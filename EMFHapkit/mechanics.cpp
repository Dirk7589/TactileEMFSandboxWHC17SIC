#include "mechanics.h"
#include "Arduino.h"
#include "kinematics.h"

void motorSetup()
{
  pinMode(5, OUTPUT);
  pinMode(8, OUTPUT);
  byte mode = 0x01;
  TCCR0B = TCCR0B & 0b11111000 | mode;
}

void renderingAlgorithm(int functionNumber, int Q1, int Q2, int S1, int S2)
{
  float Tp = 0;
  float Ke[4] = {1.0, 0.0001, 0.000001, 0.00000001};
  float r = 0.0875 - xh;
  float temp = Ke[functionNumber]*S1*Q1*S2*Q2;

  switch (functionNumber)
  {
    case 0:
      force = S1*Q1*xh;
      break;
    case 1:
      force = temp/r;
      break;
    case 2:
      force = temp/r/r;
      break;
    case 3:
      force = temp/r/r/r;
      break;
    default:
      break;
  }

  Tp = 0.2545 * force;
  forceOutput(Tp);
}

void forceOutput(float T)
{
  float duty;
  if (force > 0)
  {
    digitalWrite(8, HIGH);
  } else {
    digitalWrite(8, LOW);
  }

  duty = sqrt(abs(T));

  if (duty > 1)
  {
    duty = 1;
  } else if (duty < 0) {
    duty = 0;
  }
  
  int output = (int)(duty*255);
  
  if (xh < 0.005)
  {
    output = 0;
  }
  if (xh > 0.0825)
  {
    output = 0;
  }

  analogWrite(5,output);
}

