#ifndef LCD_INTERFACE_H
#define LCD_INTERFACE_H

#include <Arduino.h>
#include <LiquidCrystal.h>
#include "bsp.h"

class LCDInterface
{
  public:
    LCDInterface();
    void initInterface();
    void startUpMessage();
    int readButton();
    LiquidCrystal getLCD();
    void printButton(int button);
    void writeLines(String line1, String line2);
    void waitForAnyButton();
    int selectProblem(int Q1, int Q2, String & P1, String & P2);
    enum Buttons { SELECT = 4, LEFT = 3, RIGHT = 0, UP = 1, DOWN = 2, INVALID = -1};
  private:
    LiquidCrystal lcd;
    int getKey(unsigned int input);
    int NUM_KEYS = 5;
    int adc_key_val[5] = { 30, 150, 360, 535, 760 };
};

#endif
