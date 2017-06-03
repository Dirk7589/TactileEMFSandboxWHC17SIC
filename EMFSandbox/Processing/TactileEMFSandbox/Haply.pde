/*
    Useful functions from hAPI examples to draw the Haply's arms on screen. 
*/


//Creates virtual pantograph (Haply arm config), which allows updating virtual moving point
void createPantograph() {

  /* modify pantograph parameters to fit screen */
  float l_ani=pixelsPerMeter*l;
  float L_ani=pixelsPerMeter*L;
  float d_ani=pixelsPerMeter*d; 
  float r_ee_ani = pixelsPerMeter*r_ee; 
  float r_ani = 20;
  
  /* parameters for create pantograph object */ 
  pantograph = createShape();
  pantograph.beginShape();
  pantograph.fill(255);
  pantograph.stroke(0);
  pantograph.strokeWeight(2);

  pantograph.vertex(device_origin.x, device_origin.y);
  pantograph.vertex(device_origin.x, device_origin.y);
  pantograph.vertex(device_origin.x, device_origin.y);
  pantograph.vertex(device_origin.x-d_ani, device_origin.y);
  pantograph.vertex(device_origin.x-d_ani, device_origin.y);
  pantograph.endShape(CLOSE);
  

  joint1 = createShape(ELLIPSE, device_origin.x, device_origin.y, d_ani/5, d_ani/5);
  joint1.setStroke(color(0));
  
  joint2 = createShape(ELLIPSE, device_origin.x-d_ani, device_origin.y, d_ani/5, d_ani/5);
  joint2.setStroke(color(0));

  handle = createShape(ELLIPSE, device_origin.x, device_origin.y, r_ani, r_ani);
  handle.setStroke(color(0));
  handle.setFill(getMovingChargeColor());
  strokeWeight(5);
}

/*
//Updates the on-screen position of the Moving Charge (i.e. the end-effector 
you hold on the haply),based on the values returned by the Haply
*/
void updateMovingChargePosition(float th1, float th2, float x_E, float y_E){
  
  /* modify virtual object parameters to fit screen */
  x_E = pixelsPerMeter*x_E; 
  y_E = pixelsPerMeter*y_E; 
  th1 = 3.14-th1;
  th2 = 3.14-th2;
  float l_ani = pixelsPerMeter*l; 
  float L_ani = pixelsPerMeter*L; 
  float d_ani = pixelsPerMeter*d; 
  float r_ani = 20;
  
  /* Vertex A with th1 from encoder reading */
  pantograph.setVertex(1,device_origin.x+l_ani*cos(th1), device_origin.y+l_ani*sin(th1)); 
  
  /* Vertex B with th2 from encoder reading */
  pantograph.setVertex(3,device_origin.x-d_ani+l_ani*cos(th2), device_origin.y+l_ani*sin(th2)); 
  
  /* Vertex E from Fwd Kin calculations */
  pantograph.setVertex(2,device_origin.x+x_E, device_origin.y+y_E);   
  
  
  /* Display the virtual objects with new parameters */
  
  //Optional display values, will show lines representing arms if uncommented.
  //shape(pantograph); 
  //shape(joint1);
  //shape(joint2); 
  
  //Display moving point charge
  //pushMatrix(); 
  handle.setFill(getMovingChargeColor());
  shape(handle,x_E+(d/12*pixelsPerMeter), y_E);
  stroke(0); 
  //popMatrix(); 
}

// translates from device frame of reference (Haply coordinate system) to graphics frame of reference (pixel coordinate system)
PVector device2graphics(PVector deviceFrame){
   
  return deviceFrame.set(-deviceFrame.x, deviceFrame.y);  
}
 
// translates from graphics frame of reference (pixel coordinate system) to device frame of reference (Haply coordinate system)
PVector graphics2device(PVector graphicsFrame){
  
  return graphicsFrame.set(-graphicsFrame.x, graphicsFrame.y); 
}

color getMovingChargeColor(){
    if(qMovingCharge > 0){
      return color(255,0,0);
    } else if (qMovingCharge == 0)
    {
      return color(128);
    }else{
      return color(0,0,255);
    }
  }