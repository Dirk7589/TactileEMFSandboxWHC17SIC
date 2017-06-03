#ifndef TWO_CHARGES_H
#define TWO_CHARGES_H

#include "LCDInterface.h"

class TwoCharges
{
public:
  TwoCharges();
  ~TwoCharges();
  void initProblems(LCDInterface lcd, byte problemSelection);
  bool back;
  bool loc;
  int fresh;
  int menu;
  float lastF;
  int getQ1();
  int getQ2();
  int getQ1Pol();
  int getQ2Pol();
private:
  int q1 = 10;
  int q2 = 10;
  int q1Polarity = 1;
  int q2Polarity = 1;
  String getPolarityChar(int polarity);
  int increaseCharge(int charge);
  int decreaseCharge(int charge);
};

#endif
