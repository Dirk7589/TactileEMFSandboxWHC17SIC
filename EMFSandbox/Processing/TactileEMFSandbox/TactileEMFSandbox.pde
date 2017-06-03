//Include libs
import java.util.*;
import processing.serial.*;
import com.dhchoi.CountdownTimer; // need to download this library from processing. Go to Sketch -> Import Library... -> Add Library. Search for countdowntimer
import com.dhchoi.CountdownTimerService;
import g4p_controls.*;
import grafica.*;
import java.awt.Font;
import java.awt.*;

//Declare global variables
// May need to add hAPI.jar to sketch for some of these to work. Go to Sketch -> Add File... 
/* Device block definitions ********************************************************************************************/
Device            haply_2DoF;
byte              deviceID             = 5;
Board             haply_board;
DeviceType        device_type;

/* Simulation Speed Parameters ****************************************************************************************/
final long        SIMULATION_PERIOD    = 1; //ms
final long        HOUR_IN_MILLIS       = 36000000;
CountdownTimer    haptic_timer;

/* Graphics Simulation parameters *************************************************************************************/
PShape            pantograph, joint1, joint2, handle;

int               pixelsPerMeter       = 4000; 
float             radsPerDegree        = 0.01745; 

float             l                    = .05; // in m: these are length for graphic objects
float             L                    = .07;
float             d                    = .02;
float             r_ee                 = d/3; 

PVector           device_origin        = new PVector (0, 0) ; 

/* generic data for a 2DOF device */
/* joint space */
PVector           angles               = new PVector(0, 0);
PVector           torques              = new PVector(0, 0);

/* task space */
PVector           initial_pos_ee       = new PVector(0, 0);
PVector           pos_ee               = new PVector(0, 0);
PVector           f_ee                 = new PVector(0, 0);
           
/* Variables used for vector field and contour drawing */
int skip = 25;
int maxi = 29;
int maxj = 16;
double[][] F = new double[maxi*maxj][2];
double[][] phi = new double[maxi][maxj];
double maxF = 0.0;
double minF = 1000.0;
double max = -1000.0;
double min = 1000.0;

//Sandbox related variables.
Charges   fixedCharges =       new Charges();    //ArrayList of charges. Type was used to allow variability in number of elements.
int       defaultCharge =      -7;               //Some default charge in uC.
int       qMovingCharge =      0;                //Initial q of the moving charge.
PFont     f;
int       fontSize =           12;
Menu      menu;

int minSliderValue = -100;
int maxSliderValue = 100;
int numberOfTicks = 5;
PImage logo;

boolean   drawFieldLines = false;
boolean   drawEquipotentialLines = false;
boolean   showWelcomeMessage = true;
boolean   nearCharge = false;


//setup() run once at beginning of program. Processing standard function see reference for details
void setup() {
  size (1000, 500);  //Create 2D workspace of 1000px x 500px
  background(ScreenParameters.BACKGROUND_COLOR);        //Make background white
  frameRate(ScreenParameters.FRAME_RATE);         //Set framerate
  logo = loadImage("tactileEMFsandboxlogo.png");
  surface.setResizable(false); 
  f = createFont("Tahoma", fontSize, true);

   /* Initialization of the Board, Device, and Device Components */
  /* BOARD */
  haply_board = new Board(this, Serial.list()[1], 0);

  /* DEVICE */
  haply_2DoF = new Device(device_type.HaplyTwoDOF, deviceID, haply_board);
  
  /* set device in middle of frame on the x-axis and in the fifth on the y-axis */
  device_origin.add(((width*0.8)/2), (height/10) - (ScreenParameters.SCREEN_HEIGHT*0.2 + 20) );
  
  /* create pantograph graphics */  
  createPantograph();
  
  /* haptics event timer, create and start a timer that has been configured to trigger onTickEvents */
  /* every TICK (1ms or 1kHz) and run for HOUR_IN_MILLIS (1hr), then resetting */
  haptic_timer = CountdownTimerService.getNewCountdownTimer(this).configure(SIMULATION_PERIOD, HOUR_IN_MILLIS).start();
  
  menu = new Menu(this);
}
boolean firstDraw = true;
//draw() runs at framerate specified in setup(). Processing standard function see reference for details
void draw(){
  /* To clean up the left-overs of drawings from the previous loop */
   background(ScreenParameters.BACKGROUND_COLOR); 
   if(firstDraw){
     initial_pos_ee.set(pos_ee);
     firstDraw = false;
   }

   if(showWelcomeMessage){
     image(logo, (ScreenParameters.CHARGE_X_LIMIT/2)-100,(ScreenParameters.CHARGE_Y_LIMIT/2)-100, 200, 200);
   }
   drawBorder(); 
   if(drawEquipotentialLines){
     drawContour();
   }
   if(drawFieldLines){
     drawFieldLines();
   }
   updateChargeDisplay();  
   updateMovingChargePosition(angles.x*radsPerDegree, angles.y*radsPerDegree, pos_ee.x, pos_ee.y);
   updateGraph();
 
   if(pos_ee.x - initial_pos_ee.x != 0){
    menu.getWelcomeMessage().setVisible(false);
    showWelcomeMessage = false;
   }
   
}

void drawBorder(){
  strokeWeight(1);
  line(0, 0, ScreenParameters.SCREEN_WIDTH, 0);
  line(0, 0, 0, ScreenParameters.CHARGE_Y_LIMIT);
  line(ScreenParameters.CHARGE_X_LIMIT, 0, ScreenParameters.CHARGE_X_LIMIT, ScreenParameters.SCREEN_HEIGHT);
  line(0, ScreenParameters.CHARGE_Y_LIMIT, ScreenParameters.CHARGE_X_LIMIT, ScreenParameters.CHARGE_Y_LIMIT);
}

void drawContour() {
  double Fx = 0;
  double Fy = 0;
  double K = 8.9875518E-7;
  double R;
  double V = 0;
  ArrayList<Charge> chargeList = fixedCharges.getCharges();
  double scale = 1.0/pixelsPerMeter;
  
    max = -1000;
    min = 1000;
  
    for(int i = 0; i < maxi; i++) {
        for(int j = 0; j < maxj; j++) {
          for(int k = 0; k < chargeList.size(); k++) {
            Fx = scale*(skip*i+12 - chargeList.get(k).getCoordX());
            Fy = scale*(skip*j+12 - chargeList.get(k).getCoordY());
            R = Math.sqrt(Fx*Fx + Fy*Fy);
            V += chargeList.get(k).getCharge()*K/R;
          }
                    
          if(V > max) {
            max = V;
          }
          if(V < min) {
            min = V; 
          }
          phi[i][j] = V;
          V = 0;
        }
     }
     
     int[] Red = {0,0,0,0,0,0,0,64,128,191,255,255,255,255,255,191,128};
     int[] Green = {0,0,0,64,128,191,255,255,255,255,255,191,128,64,0,0,0};
     int[] Blue = {143,191,255,255,255,255,255,191,128,64,0,0,0,0,0,0,0};
     double val = 0;
     int c;
     
     //System.out.println(max);
     //System.out.println(min);
     
     for(int i = 0; i < maxi-1; i++) {
        for(int j = 0; j < maxj-1; j++) {
          for(int k = 0; k < 17; k++) {
            
            val = (max/2-min/2)*(17-k)/17 + min/2;
            c = (int)(533.3*val+8);
            if(c > 16) {
              c = 16;
            }
            if(c < 0) {
              c = 0;
            }
            
            contourLines(i,j,skip,val,Red[c],Green[c],Blue[c]);
          }
          
        }
     }
  
}

int sgn(double x) {
  
  int sign = 0;
 
  if(x > 0) {
    sign = 1;
  } else {
    sign = -1;
  }
  return sign;
}

void contourLines(int i, int j, int L, double p0,int R, int G, int B){
  
  int[] pts = new int[4];
  int k = 0;
  double x;
  
  x = (p0-phi[i][j])*L/(phi[i+1][j]-phi[i][j]);
  if((x > 0) && (x < L)) {
    pts[k] = skip*i+12+(int)x;
    pts[k+1] = skip*j+12;
    k = 2;
  }
  x = (p0-phi[i][j])*L/(phi[i][j+1]-phi[i][j]);
  if((x > 0) && (x < L)) {
    pts[k] = skip*i+12;
    pts[k+1] = skip*j+12+(int)x;
    k = 2;
  }
  x = (p0-phi[i][j+1])*L/(phi[i+1][j+1]-phi[i][j+1]);
  if((x > 0) && (x < L)) {
    pts[k] = skip*i+12+(int)x;
    pts[k+1] = skip*(j+1)+12;
    k = 2;
  }
  x = (p0-phi[i+1][j])*L/(phi[i+1][j+1]-phi[i+1][j]);
  if((x > 0) && (x < L)) {
    pts[k] =  skip*(i+1)+12;
    pts[k+1] = skip*j+12+(int)x;
  }
  
  stroke(R,G,B);
  strokeWeight(2);
  line(pts[0],pts[1],pts[2],pts[3]);
  
}

void drawFieldLines(){
  //Draw the lines here
  PVector force = new PVector(0, 0);
  ArrayList<Charge> chargeList = fixedCharges.getCharges();
  double K = 8.9875518E-7;
  double Fx = 0;
  double Fy = 0;
  double R;
  double mag;
  double ang;
  double scale = 1.0/pixelsPerMeter;
  int L;
  
  
     for(int i = 0; i < maxi; i++) {
        for(int j = 0; j < maxj; j++) {
          for(int k = 0; k < chargeList.size(); k++) {
            Fx = scale*(skip*i+12 - chargeList.get(k).getCoordX());
            Fy = scale*(skip*j+12 - chargeList.get(k).getCoordY());
            R = pow((float)(Fx*Fx + Fy*Fy), 1.5);
            Fx *= chargeList.get(k).getCharge()*K/R;
            Fy *= chargeList.get(k).getCharge()*K/R;
            force.add((float)Fx,(float)Fy);
          }
          mag = Math.sqrt(force.x*force.x + force.y*force.y);
          ang = Math.atan2(force.y,force.x)*180/3.14159;
          if (ang < 0) {
            ang = ang + 360;
          }
          
          if(mag > maxF) {
            maxF = mag;
          }
          if(mag < minF) {
            minF = mag; 
          }
          F[maxi*j+i][0] = mag;
          F[maxi*j+i][1] = ang;
          force.set(0.0,0.0);
        }
     }
     for(int i = 0; i < maxi; i++) {
        for(int j = 0; j < maxj; j++) {
          L = (int)(200.0*(F[maxi*j+i][0] - minF)+5);
          //L = (int)(2000/(maxF-minF)*(F[maxi*j+i][0]-minF));
          
          if(L > 15) {
            L = 15;
          }
          drawArrow(skip*i+12,skip*j+12,L,(float)F[maxi*j+i][1],1);
        }
    }
}

void updateGraph(){
  if(menu.getPlot().getPoints().getNPoints() > 0){
    menu.getPlot().removePoint(0);
  }
  menu.getPlot().addPoint(0,f_ee.mag(), "Moving charge");
  menu.getPlot().beginDraw();
  menu.getPlot().drawBackground();
  menu.getPlot().drawBox();
  menu.getPlot().drawYAxis();
  menu.getPlot().drawTitle();
  menu.getPlot().drawHistograms();
  menu.getPlot().endDraw();
}

//onTickEvent() runs at the rate specified by haptic_timer. This would be our haptic loop function
void onTickEvent(CountdownTimer t, long timeLeftUntilFinish){
  //Haptic Loop code goes here.
  
  /* check if new data is available from physical device */
  if (haply_board.data_available()) {

    /* GET END-EFFECTOR POSITION (TASK SPACE) */
    //Gets angles from Haply
    angles.set(haply_2DoF.get_device_angles()); 
    //Finds position based on angles
    pos_ee.set( haply_2DoF.get_device_position(angles.array()));
    //Converts position from device's reference frame to pixel coordinates.
    pos_ee.set(device2graphics(pos_ee));    
    //Calculate forces
    f_ee = calculateForce();
    //Convert the force from pixel coordinates to device frame of reference
    f_ee.set(graphics2device(f_ee));
  }

  /* update device torque in simulation and on physical device */
  haply_2DoF.set_device_torques(f_ee.array());
  torques.set(haply_2DoF.mechanisms.get_torque());
  haply_2DoF.device_write_torques();
  return;
}

//Other functions to be called

//Called whenever mouse is pressed. Processing standard function see reference for details
void mousePressed(){
  if(showWelcomeMessage){
    menu.getWelcomeMessage().setVisible(false);
    showWelcomeMessage = false;
  }
  //Create Charge object with position of (mouseX, mouseY) and some default charge.
  if(mouseX < ScreenParameters.CHARGE_X_LIMIT && mouseY < ScreenParameters.CHARGE_Y_LIMIT){
    
    //Add array with charge information to vector conatining charges.
    fixedCharges.addCharge(mouseX, mouseY, this);
    if(!menu.getPresetOptions()[0].isSelected()){
      menu.getPresetOptions()[0].setSelected(true);
    }
  }
}

//Function to calculate Force in haptic loop based on haply location and list of charges.
PVector calculateForce(){
  
  PVector force = new PVector(0, 0);
  ArrayList<Charge> chargeList = fixedCharges.getCharges();
  double K = 8.9875518E-8;
  double Fx;
  double Fy;
  double R;
  double scale = 1.0/pixelsPerMeter;
  double dampingFactor =0;
  
  for (int i = 0; i < chargeList.size(); i++) {
	  // Note that scale controls how pixel distances map to metres.
	  Fx = scale*(((pos_ee.x*pixelsPerMeter)+device_origin.x) - (chargeList.get(i).getCoordX()));
	  Fy = scale*(((pos_ee.y*pixelsPerMeter)+device_origin.y) - (chargeList.get(i).getCoordY()));
	  R = pow((float)(Fx*Fx + Fy*Fy), 1.5);
    if(R < (1E-7)){
      nearCharge = true;
      float C = 5E5; //Some constant determined qualitatively 5E5
      dampingFactor = 1 - Math.exp(-C*(R));
    }
	  Fx *= qMovingCharge*chargeList.get(i).getCharge()*K/R;
	  Fy *= qMovingCharge*chargeList.get(i).getCharge()*K/R;
	  force.add((float)Fx,(float)Fy);
  } 
  
  if(nearCharge){
    //Apply damping
    force.mult((float) dampingFactor);
    nearCharge = false; 
  }
  
  return force;
}

void drawArrow(int cx, int cy, int len, float angle, float thickness){
  stroke(0,0,0);
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  strokeWeight(thickness);
  line(0,0,len, 0);
  strokeWeight(thickness);
  line(len, 0, len - 3, -3);
  strokeWeight(thickness);
  line(len, 0, len - 3, 3);
  popMatrix();
}
  
 // haptic timer reset. Function is called when the CountdownTimer resets after one hour.
void onFinishEvent(CountdownTimer t){
  println("Resetting timer...");
  haptic_timer.reset();
  haptic_timer = CountdownTimerService.getNewCountdownTimer(this).configure(SIMULATION_PERIOD, HOUR_IN_MILLIS).start();
}