#ifndef KINEMATICS_H
#define KINEMATICS_H

#define MAXPOS  972
#define MINPOS  49
#define THRESH  400
#define m       0.0140
#define rh      0.0714

extern int MR;
extern int lastMR;
extern int diff;
extern int pos;
extern int lastDiff;
extern int predict;
extern bool warn;
extern float xh;
extern float force;

int sgn(int x);
void updateSensorPosition(void);
void initializeSensor(void);
void computePosition(void);


#endif
