#include "kinematics.h"
#include <Arduino.h>

int MR = 0;
int lastMR = 0;
int diff = 0;
int pos = 0;
int lastDiff = 0;
int predict = 0;
bool warn = false;
float xh = 0;
float force = 0;

void initializeSensor()
{ 
  pinMode(A2, INPUT);
  lastMR = analogRead(A2);
}

int sgn(int x)
{
 return (x > 0) - (x < 0);
}

void updateSensorPosition()
{
  MR = analogRead(A2);
  diff = MR - lastMR;

  predict = lastMR + lastDiff;
  if ((predict > MAXPOS) || (predict < MINPOS))
  {
    warn = true;
  }
  if ((abs(diff) > THRESH) && warn)
  {
    if (sgn(diff) != sgn(lastDiff))
    {
      if (diff < 0)
      {
        pos += (MR - MINPOS) + (MAXPOS - lastMR);
      } else {
        pos -= (lastMR - MINPOS) + (MAXPOS - MR);
      }
    }
    warn = false;
  } else {
    pos += diff;
  }

  lastMR = MR;
  lastDiff = diff;
    
}

void computePosition()
{
  float theta_s;
  theta_s = m*pos;
  xh = rh*theta_s*(3.14159/180);
}

