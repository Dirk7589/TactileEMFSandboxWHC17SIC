#include "LCDInterface.h"
#include "bsp.h"
#include "kinematics.h"
#include "TwoCharges.h"
#include "mechanics.h"
#include <LiquidCrystal.h>

LCDInterface lcd;
TwoCharges twoCharges;
int problemSelect = 0;

void setup() {
  // put your setup code here, to run once:
  lcd.initInterface();
  lcd.startUpMessage();
  lcd.getLCD().blink();
  lcd.writeLines(" Pull toward S"," Press any key");
  lcd.waitForAnyButton();  
  String plus = "+";
  problemSelect = lcd.selectProblem(10,10,plus,plus);
  initializeSensor();
  motorSetup();
}

void loop() {
  // put your main code here, to run repeatedly:

  //unsigned long time1;
  //unsigned long time2;
  
  updateSensorPosition();
  computePosition();

  twoCharges.initProblems(lcd, problemSelect);

  
  int Q1 = twoCharges.getQ1();
  int Q2 = twoCharges.getQ2();
  int Q1p = twoCharges.getQ1Pol();
  int Q2p = twoCharges.getQ2Pol();
    
  renderingAlgorithm(problemSelect, Q1, Q2, Q1p, Q2p);
  
  //Serial.println((time2-time1)/64.0);
}
