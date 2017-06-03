#include "VirtualEnvironment.h"
#include <Arduino.h>

String getProblem(int selection)
{
  switch (selection)
  {
  case 0:
    return "Hooke's Law";
    break;
  case 1:
    return "Inf Line Charge";
    break;
  case 2:
    return "Coulomb's Law";
    break;
  case 3:
    return "Dipole Law";
    break;
  default:
    break;
  }
  return "";
}
