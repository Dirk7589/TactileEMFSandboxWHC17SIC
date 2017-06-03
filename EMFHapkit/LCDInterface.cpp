#include "LCDInterface.h"
#include <Arduino.h>
#include "VirtualEnvironment.h"

// VERSION NUMBER STRING STARTUP TEXT
String version = "EMF Hapkit  v1.2";

LCDInterface::LCDInterface() : lcd(LCD_RS, LCD_EN, LCD_D4, LCD_D5, LCD_D6, LCD_D7){}

int LCDInterface::readButton(){
  
  int adc_key_in = 1023;
  int key = -1;
  adc_key_in = analogRead(ANALOG_BUTTON_INPUT);    // read the value from the sensor  
  key = getKey(adc_key_in);		        // convert into key press
  while (adc_key_in < 1000){
    adc_key_in = analogRead(ANALOG_BUTTON_INPUT);
  }
  return key;
}

int LCDInterface::getKey(unsigned int input){
  int k;

  for (k = 0; k < NUM_KEYS; k++)
  {
    if (input < adc_key_val[k])
    {
      return k;
    }
  }

  if (k >= NUM_KEYS)
    k = -1;     // No valid key pressed

  return k;
}

void LCDInterface::initInterface(){
  lcd.begin(16, 2);
  pinMode(ANALOG_BUTTON_INPUT, INPUT);
  return;
}

LiquidCrystal LCDInterface::getLCD(){
  return lcd;
}


String storedLine1 = "";
String storedLine2 = "";

void LCDInterface::writeLines(String line1, String line2){
  if (line1.equals(storedLine1) && line2.equals(storedLine2)){
    return;
  }
  storedLine1 = line1;
  storedLine2 = line2;
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(line1);
  lcd.setCursor(0, 1);
  lcd.print(line2);
  
}

void LCDInterface::waitForAnyButton(){
  while (readButton() == INVALID);
  return;
}

int LCDInterface::selectProblem(int Q1, int Q2, String & P1, String & P2)
{
  int problem = 0;
  int buttonVal = -1;
    
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Select Problem:");
  lcd.setCursor(0, 1);
  lcd.print("Hooke's Law");

  while (buttonVal != 4)
  {
    buttonVal = -1;
    while (buttonVal == -1)
      buttonVal = readButton();
    switch(buttonVal)
    {
    case 3:
	  problem--;
	  if (problem < 0)
	    problem = 3;
      break;
    case 0:
      problem++;
	  if (problem > 3)
        problem = 0;
      break; 
    default:
      break;
    }
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Select Problem:");
    lcd.setCursor(0, 1);
    lcd.print(getProblem(problem));
  }

  lcd.clear();
  lcd.setCursor(0,0);
  switch(problem)
  {
    case 0:
      //lcd.print(" K=+10 N/m");
      lcd.print(" K=" + P1 + Q1 + " N/m");
      break;
    case 1:
      //lcd.print("Q1=+10 Q2=+ 1uC");
      lcd.print("QL=" + P1 + Q1 + " Q =" + P2 + "." + Q2/10 + "uC");
      break;
    case 2:
      //lcd.print("Q1=+1  Q2=+.1 uC");
      lcd.print("Q1=" + P1 + Q1/10 + "  Q2=" + P2 + "." + Q2/10 + " uC");
      break;
    case 3:
      //lcd.print("Q1=+100Q2=+ 10nC");
      lcd.print("Q1=" + P1 + Q1*10 + "Q2=" + P2 + " " + Q2 + "nC");
      break;
    default:
      break;
  }
  lcd.setCursor(0,1);
  lcd.print("Force = +0.000N");
  lcd.setCursor(0,1);
  return problem;
}

void LCDInterface::startUpMessage(){
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(version);
  lcd.setCursor(0, 1);
  lcd.print(" Press any key");
  waitForAnyButton();
}
