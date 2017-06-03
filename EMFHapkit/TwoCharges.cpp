#include "TwoCharges.h"
#include "kinematics.h"

extern int problemSelect;

void TwoCharges::initProblems(LCDInterface lcd, byte problemSelection){

  LiquidCrystal display = lcd.getLCD();
  int buttonValue = -1;
  int menuX[5] = {3, 4, 10, 12, 0};
  int menuY[5] = {0, 0, 0, 0, 1};
  float Q1m[4] = {1, 1, 0.1, 10};
  float Q2m[4] = {0, 0.1, 0.1, 1};
  float disp;
  String str1;
  String str2;
  
  if (!back && (abs(force - lastF) > 0.001))
  {
    display.setCursor(8,1);
    if (loc) {
      disp = xh*100;
    } else {
      disp = force;
    }
    if (disp >= 0)
    {
      display.print("+");
    } else {
      display.print("-");
    }
    if (loc) {
      display.print(String(abs(disp),2) + "cm");
    } else {
      display.print(String(abs(disp),3) + "N");
    }
    //display.print(String(xh*100,3));
    lastF = force;
  }

  buttonValue = lcd.readButton();
  if (buttonValue != -1)
  {
    switch(buttonValue)
    {
      case LCDInterface::LEFT:
      {
        menu--;
        if (menu < 0)
          menu = 4;
        if (problemSelection == 0 && menu == 3)
          menu = 1;
        break;
      }
      case LCDInterface::RIGHT:
      {
        menu++;
        if (menu > 4)
          menu = 0;
        if (problemSelection == 0 && menu == 2)
          menu = 4;
        break;
      }
      case LCDInterface::SELECT:
      {
        if (menu == 4 && back)
          {
          str1 = getPolarityChar(q1Polarity);
          str2 = getPolarityChar(q2Polarity);
          problemSelect = lcd.selectProblem(q1,q2,str1,str2);
          lastF = 0;
          back = false;
          }
        break;
      }
      default:
      {
        switch(menu)
        {
          case 4:
            if (back)
            {
              back = false;
              loc = false;
            } else if (loc) {
              loc = false;
              back = true;
            } else {
              loc = true;
              back = false;
            }
            //back = !back;
            display.setCursor(0,1);
            if (back)
            {
              display.print("Back            ");
            } else  if(loc) {
              display.print("Dist. = +0.00cm");
            } else {
              display.print("Force = +0.000N");
            }
            break;
          case 0:
            q1Polarity = -q1Polarity;
            display.setCursor(3,0);
            display.print(getPolarityChar(q1Polarity));
            break;
          case 2:
            q2Polarity = -q2Polarity;
            display.setCursor(10,0);
            display.print(getPolarityChar(q2Polarity));
            break;
          case 1:
            if (buttonValue == LCDInterface::UP)
            {
              q1 = increaseCharge(q1);
            } else {
              q1 = decreaseCharge(q1);
            }
            display.setCursor(4,0);
            display.print((int)(q1*Q1m[problemSelect]));
            break;
          case 3:
            if (buttonValue == LCDInterface::UP)
            {
              q2 = increaseCharge(q2);
            } else {
              q2 = decreaseCharge(q2);
            }
            display.setCursor(12,0);
            display.print((int)(q2*Q2m[problemSelect]));
            break;
          default:
            break;
        }
        break;
      }
    }
  }
  display.setCursor(menuX[menu],menuY[menu]);
}

int TwoCharges::increaseCharge(int charge){
  charge = charge + 10;
  if (charge >= 100){
    charge = 10;
  }
  return charge;
}

int TwoCharges::decreaseCharge(int charge){
  charge = charge - 10;
  if (charge < 10){
    charge = 90;
  }
  return charge;
}

String TwoCharges::getPolarityChar(int polarity){
  if (polarity == -1){
    return "-";
  }
  else if (polarity == 1){
    return "+";
  }
  else{
    return "ERROR";
  }
}

TwoCharges::TwoCharges() {
  
  back = false;
  fresh = 0;
  lastF = 0;
  menu = 4;
  loc = false;
  }

int TwoCharges::getQ1(){
  return q1;
}

int TwoCharges::getQ2(){
  return q2;
}

int TwoCharges::getQ1Pol(){
  return q1Polarity;
}

int TwoCharges::getQ2Pol(){
  return q2Polarity;
}

TwoCharges::~TwoCharges() {}
